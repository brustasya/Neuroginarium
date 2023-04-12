//
//  RatingViewController.swift
//  Neuroginarium
//
//  Created by Станислава on 30.03.2023.
//

import UIKit

class RatingViewController: UIViewController {
    
    let userService = UserService()
    
    private lazy var userId = 0
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Рэйтинг"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = Colors.white.uiColor
        return label
    }()
    
    private let userRankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.register(PlayerRatingTableViewCell.self, forCellReuseIdentifier: "PlayerRatingTableViewCell")
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private lazy var users: [UserNicknameRatingDto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "back")
        let backgroundImageView = UIImageView(image: backgroundImage)
        view.addSubview(backgroundImageView)
        backgroundImageView.frame = view.frame
        view.sendSubviewToBack(backgroundImageView)
        
        configureUI()        
    }
    
    private func configureUI() {
        navigationItem.titleView = titleLabel
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .done,
            target: self,
            action: #selector(goBack)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        view.addSubview(userRankLabel)
        userRankLabel.translatesAutoresizingMaskIntoConstraints = false
        userRankLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        userRankLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        userRankLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor.clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: userRankLabel.bottomAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Ошибка соединения", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        let retryAction = UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.getRating()
        })
        
        alertController.addAction(okAction)
        alertController.addAction(retryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func getRating() {
        userService.getRating(userId: userId) { [weak self] result in
            switch result {
            case .success(let rating):
                DispatchQueue.main.async {
                    self?.userRankLabel.text = "Вы занимаете \(rating.position) место\nс результатом \(rating.points) б."
                }
                print("User rating is: \(rating)")
            case .failure(let error):
                print("Error occurred: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.showAlert()
                }
            }
        }
        
        userService.getTop50Users { [weak self] result in
            switch result {
            case .success(let users):
                print(users)
                DispatchQueue.main.async {
                    self?.users = users
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self?.showAlert()
                }
            }
        }
    }
    
    @objc private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configure(with userId: Int) {
        self.userId = userId
        getRating()
    }
}

extension RatingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerRatingTableViewCell", for: indexPath) as? PlayerRatingTableViewCell else {
            return UITableViewCell()
        }
        let player = users[indexPath.row]
        cell.configure(rank: indexPath.row + 1, userNicknameRatingDto: player)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Colors.blue.uiColor
        
        let rankLabel = UILabel()
        rankLabel.text = "Место"
        rankLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        rankLabel.textAlignment = .left
        headerView.addSubview(rankLabel)
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        rankLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        rankLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        rankLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Имя игрока"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textAlignment = .center
        headerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 20).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        let scoreLabel = UILabel()
        scoreLabel.text = "Баллы"
        scoreLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        scoreLabel.textAlignment = .center
        headerView.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
        scoreLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        return headerView
    }
    
}

