//
//  UserService.swift
//  Neuroginarium
//
//  Created by Станислава on 02.04.2023.
//

import UIKit

class UserService {
    
    // MARK: - registration-controller

    private let baseURL = "http://158.160.26.234:8080"
    
    func checkEmailConfirmationToken(token: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/registration/\(email)/check?token=\(token)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }
            
            if httpResponse.statusCode == 200 {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "Invalid Status Code", code: httpResponse.statusCode, userInfo: nil)))
            }
        }
        
        task.resume()
    }

    func addUser(createUserDto: Encodable, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/registration/addUser") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(createUserDto)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Server error", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }

    func sendEmailConfirmation(for email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/registration/\(email)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Bad response", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }

    // MARK: - user-controller
    
    func getUserInfoByPlayerId(playerId: Int64, completion: @escaping (Result<UserInfoDto, Error>) -> Void) {
        let urlString = "\(baseURL)/user/\(playerId)/nickname"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "Unknown error", code: 0, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let userInfo = try decoder.decode(UserInfoDto.self, from: data)
                completion(.success(userInfo))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    func getUserInfoById(userId: Int, completion: @escaping (Result<UserInfoDto, Error>) -> Void) {
        let urlString = "\(baseURL)/user/\(userId)/nickname"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.unknown)))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let userInfo = try decoder.decode(UserInfoDto.self, from: data)
                completion(.success(userInfo))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - rating-controller
    
    func getTop50Users(completion: @escaping (Result<[UserNicknameRatingDto], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/rating") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let jsonData = data else {
                completion(.failure(URLError(.unknown)))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let users = try decoder.decode([UserNicknameRatingDto].self, from: jsonData)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func getRating(userId: Int, completionHandler: @escaping (Result<UserRatingDto, Error>) -> Void) {
        let urlString = "\(baseURL)/rating/\(userId)"
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(NSError(domain: "Invalid HTTP response", code: 0, userInfo: nil)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(NSError(domain: "Invalid HTTP status code", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(NSError(domain: "No data returned", code: 0, userInfo: nil)))
                return
            }
            
            guard let rating = try? JSONDecoder().decode(UserRatingDto.self, from: data) else {
                completionHandler(.failure(NSError(domain: "Failed to parse response data", code: 0, userInfo: nil)))
                return
            }
            
            completionHandler(.success(rating))
        }.resume()
    }

    // MARK: - auth-controller
    
    func authorize(nickname: String, password: String, completion: @escaping (Result<UserInfoDto, Error>) -> Void) {
        let urlString = "\(baseURL)/auth?nickname=\(nickname)&password=\(password)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Bad Response", code: 0, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let userInfo = try decoder.decode(UserInfoDto.self, from: data)
                completion(.success(userInfo))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
