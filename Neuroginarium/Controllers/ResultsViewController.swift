//
//  ResultsViewController.swift
//  Neuroginarium
//
//  Created by Станислава on 30.03.2023.
//

import UIKit


class ResultsViewController: UIViewController {
    
    private lazy var userId = 0
    private lazy var gameId = 0
    private lazy var roundId = 0
    
    private lazy var gameService = GameService()
    private lazy var userService = UserService()
    
    private lazy var players: [UserPointsDto] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Результаты"
        label.textColor = Colors.white.uiColor
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PlayerTableViewCell.self, forCellReuseIdentifier: "PlayerCell")
        tableView.backgroundColor = UIColor.clear
        // tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        tableView.tableHeaderView?.backgroundColor = .white
        return tableView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "image_name"))
        //imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Продолжить", for: .normal)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(Colors.lightOrange.uiColor, for: .normal)
        
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.layer.borderColor = Colors.lightOrange.uiColor.cgColor
        button.layer.borderWidth = 4
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "back")
        let backgroundImageView = UIImageView(image: backgroundImage)
        view.addSubview(backgroundImageView)
        backgroundImageView.frame = view.frame
        view.sendSubviewToBack(backgroundImageView)

        navigationItem.titleView = titleLabel
        self.navigationItem.hidesBackButton = true
        
        setupTableView()
        setupContinueButton()
        setupImageView()
        // setupWinnerView()
    }
    
    private func setupWinnerView() {
        let nameLabel = UILabel()
        nameLabel.text = "Победил Karim!"
        nameLabel.font = .boldSystemFont(ofSize: 32)
        nameLabel.textColor = Colors.darkBlue.uiColor
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let winnerView = UIView()
        winnerView.backgroundColor = Colors.white.uiColor
        view.addSubview(winnerView)
        view.addSubview(nameLabel)
        winnerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            winnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -200),
            winnerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            winnerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            winnerView.heightAnchor.constraint(equalToConstant: 200),
            
            nameLabel.centerXAnchor.constraint(equalTo: winnerView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: winnerView.centerYAnchor)
        ])
          
        continueButton.setTitle("Завершить", for: .normal)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 350),
        ])

        tableView.tableHeaderView = nil
        tableView.allowsSelection = false

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Загаданная карточка"
        descriptionLabel.textColor = Colors.darkBlue.uiColor
        descriptionLabel.font = .boldSystemFont(ofSize: 18)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: continueButton.topAnchor, constant: -16),
            // imageView.heightAnchor.constraint(equalToConstant: 300),
            // imageView.widthAnchor.constraint(equalToConstant: 250)
        ])
        
        // imageView.image = UIImage(named: "image3")

    }
    
    private func setupContinueButton() {
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: 40),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func decodeImage(from base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            print("nil")
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    func configure(_ gameId: Int, _ userId: Int, _ roundId: Int) {
        self.gameId = gameId
        self.userId = userId
        self.roundId = roundId
        
        gameService.getRoundPoints(roundId: roundId) { [weak self] result in
            switch result {
            case .success(let roundPoints):
                print(roundPoints.usersPoints)
                DispatchQueue.main.async {
                    self?.imageView.image = self?.decodeImage(from: roundPoints.realImage)
                    self?.players = roundPoints.usersPoints
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error getting round points: \(error.localizedDescription)")
            }
        }

    }
    
    @objc private func continueButtonTapped() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.continueButton.backgroundColor = Colors.darkBlue.uiColor
        }, completion: { finished in
            UIView.animate(withDuration: 0.4, animations: {
                self.continueButton.backgroundColor = UIColor.clear
                
                let gameVC = GameViewController()
                gameVC.configure(self.gameId, self.userId)
                
                self.navigationController?.pushViewController(gameVC, animated: true)
            })
        })
    }
}


// MARK: - Table view delegate
extension ResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! PlayerTableViewCell
        
        cell.configure(players[indexPath.row], indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 
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
        rankLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        rankLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        rankLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Имя\nигрока"
        nameLabel.numberOfLines = 2
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textAlignment = .center
        headerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 32).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        let scoreSumLabel = UILabel()
        scoreSumLabel.text = "Сумма\nбаллов"
        scoreSumLabel.numberOfLines = 2
        scoreSumLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        scoreSumLabel.textAlignment = .center
        headerView.addSubview(scoreSumLabel)
        scoreSumLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreSumLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
        scoreSumLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        let scoreLabel = UILabel()
        scoreLabel.text = "Баллы\nза раун"
        scoreLabel.numberOfLines = 2
        scoreLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        scoreLabel.textAlignment = .center
        headerView.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.trailingAnchor.constraint(equalTo: scoreSumLabel.leadingAnchor, constant: -32).isActive = true
        scoreLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
}
