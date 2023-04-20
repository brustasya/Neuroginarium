//
//  GameService.swift
//  Neuroginarium
//
//  Created by Станислава on 01.04.2023.
//

import UIKit

class GameService {
    
    private let baseURL = "http://158.160.26.234:8080"
    
    // MARK: - Put requests
    func joinGame(userId: Int, gameToken: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let urlString = "\(baseURL)/game/join?user_id=\(userId)&gameToken=\(gameToken)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data,
                  let gameId = try? JSONDecoder().decode(Int.self, from: data)
            else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(gameId))
        }.resume()
    }

    // MARK: - Post requests
    func startGame(gameToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/game/start?gameToken=\(gameToken)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }

            if (200..<300).contains(httpResponse.statusCode), let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                completion(.success(responseString))
            } else {
                completion(.failure(NSError(domain: "Request failed", code: httpResponse.statusCode, userInfo: nil)))
            }
        }

        task.resume()
    }

    func vote(roundId: Int, userId: Int, cardId: Int, completionHandler: @escaping (Result<VotingResult, Error>) -> Void) {
        let urlString = "\(baseURL)/game/rounds/\(roundId)/vote?user_id=\(userId)&card_id=\(cardId)"
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неправильный URL"])))
            return
        }
        print(urlString)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            guard let data = data else {
                completionHandler(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных в ответе"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let votingResult = try decoder.decode(VotingResult.self, from: data)
                completionHandler(.success(votingResult))
            } catch {
                completionHandler(.failure(error))
            }
        }

        task.resume()
    }
    
    func giveAssociation(roundId: Int, association: String, cardId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURL)/game/rounds/\(roundId)/make_association?association=\(association)&card_id=\(cardId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }

    func giveCard(roundId: Int, cardId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/game/rounds/\(roundId)/give_card?card_id=\(cardId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(()))
        }
        task.resume()
    }

    func createGame(userId: Int, completion: @escaping (Result<GameCreateResponse, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/game/create?user_id=\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(error ?? NSError(domain: "error", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GameCreateResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - GET requests
    func findGame(userId: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        guard var components = URLComponents(string: "\(baseURL)/game") else {
            completion(.failure(NSError(domain: "error", code: -1, userInfo: nil)))
            return
        }
        components.queryItems = [URLQueryItem(name: "user_id", value: String(userId))]
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "error", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(error ?? NSError(domain: "error", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let gameID = try JSONDecoder().decode(Int.self, from: data)
                completion(.success(gameID))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    func getGame(id: Int, completion: @escaping (Result<GameDto, Error>) -> Void) {
        let urlString = "\(baseURL)/game/\(id)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            do {
                let gameDto = try JSONDecoder().decode(GameDto.self, from: data)
                completion(.success(gameDto))
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }

    func getWinner(gameId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/game/\(gameId)/winner"
        guard let url = URL(string: baseURL + endpoint) else {
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
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Request failed", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            guard let data = data, let winner = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(winner))
        }.resume()
    }

    func getCurrentRound(id: Int, completion: @escaping (Result<GameRoundDto, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/game/\(id)/rounds/current") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }
            do {
                let gameRound = try JSONDecoder().decode(GameRoundDto.self, from: data)
                completion(.success(gameRound))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func getRound(roundId: Int, completion: @escaping (Result<GameRoundDto, Error>) -> Void) {
        let urlString = "\(baseURL)/game/rounds/\(roundId)"
        guard let url = URL(string: urlString) else {
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
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data,
                  let gameRoundDto = try? JSONDecoder().decode(GameRoundDto.self, from: data)
            else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(gameRoundDto))
        }.resume()
    }

    
    func getPlayers(id: Int, completion: @escaping (Result<[PlayerDto], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/game/\(id)/players") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }
            do {
                let players = try JSONDecoder().decode([PlayerDto].self, from: data)
                completion(.success(players))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func getCardsOnTable(id: Int, completion: @escaping (Result<[CardDto], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/game/\(id)/cards_on_table") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }
            do {
                let cards = try JSONDecoder().decode([CardDto].self, from: data)
                completion(.success(cards))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func getPlayerCards(gameId: Int, userId: Int, completion: @escaping (Result<[CardDto], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/game/\(gameId)/cards/\(userId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }
            do {
                let cards = try JSONDecoder().decode([CardDto].self, from: data)
                completion(.success(cards))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func getRoundPoints(roundId: Int, completion: @escaping (Result<RoundPointsDto, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/game/rounds/\(roundId)/get_points") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(NSError(domain: "Unexpected response", code: 0, userInfo: nil)))
                return
            }
            do {
                let roundPoints = try JSONDecoder().decode(RoundPointsDto.self, from: data)
                completion(.success(roundPoints))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func getAssociation(roundId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/game/rounds/\(roundId)/get_association") else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let data = data, let association = String(data: data, encoding: .utf8) else {
                return completion(.failure(NSError(domain: "Invalid Data", code: 0, userInfo: nil)))
            }
            
            completion(.success(association))
        }
        
        task.resume()
    }
}
