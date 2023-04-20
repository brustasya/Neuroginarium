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
    
    private lazy var descriptionLabel = UILabel()
    private lazy var nameLabel = UILabel()
    private lazy var winnerView = UIView()
    
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
    
    let endButton: UIButton = {
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
        setupWinnerView()
    }
    
    private func setupWinnerView() {
        nameLabel.font = .boldSystemFont(ofSize: 28)
        nameLabel.textColor = Colors.white.uiColor
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        winnerView.backgroundColor = Colors.darkBlue.uiColor
        winnerView.layer.borderColor = Colors.white.uiColor.cgColor
        winnerView.layer.borderWidth = 3
        winnerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(winnerView)
        view.addSubview(nameLabel)
        view.addSubview(endButton)
        
        NSLayoutConstraint.activate([
            winnerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            winnerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            winnerView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 100),
            winnerView.bottomAnchor.constraint(equalTo: endButton.topAnchor, constant: -220),
            
            nameLabel.centerXAnchor.constraint(equalTo: winnerView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: winnerView.centerYAnchor),
            
            endButton.heightAnchor.constraint(equalToConstant: 40),
            endButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            endButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            endButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        endButton.addTarget(self, action: #selector(endButtonTapped), for: .touchUpInside)
        
        winnerView.isHidden = true
        nameLabel.isHidden = true
        endButton.isHidden = true
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
        
        descriptionLabel.text = "Загаданная карточка"
        descriptionLabel.textColor = Colors.darkBlue.uiColor
        descriptionLabel.font = .boldSystemFont(ofSize: 20)
        // descriptionLabel.backgroundColor = Colors.lightOrange.uiColor
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: continueButton.topAnchor, constant: -16),
        ])
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
                
                self.gameService.getGame(id: self.gameId) { [weak self]  result in
                    switch result {
                    case .success(let gameDto):
                        print(gameDto)
                        if (gameDto.gameStatus == GameStatus.finished) {
                            DispatchQueue.main.async {
                                self?.descriptionLabel.isHidden = true
                                self?.imageView.isHidden = true
                                self?.continueButton.isHidden = true
                                
                                self?.endButton.isHidden = false
                                self?.winnerView.isHidden = false
                                self?.nameLabel.isHidden = false
                            }
                            
                            self?.gameService.getWinner(gameId: self?.gameId ?? 0) { [weak self] result in
                                switch result {
                                case .success(let name):
                                    DispatchQueue.main.async {
                                        self?.nameLabel.text = "Победил \(name)!"
                                    }
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                let gameVC = GameViewController()
                                gameVC.configure(self?.gameId ?? 0, self?.userId ?? 0)
                                
                                self?.navigationController?.pushViewController(gameVC, animated: true)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            })
        })
    }
    
    @objc private func endButtonTapped() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.endButton.backgroundColor = Colors.darkBlue.uiColor
        }, completion: { finished in
            UIView.animate(withDuration: 0.4, animations: {
                self.endButton.backgroundColor = UIColor.clear
                
                let startVC = StartViewController()
                startVC.configure(with: self.userId)
                self.navigationController?.pushViewController(startVC, animated: true)
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
        scoreLabel.text = "Баллы\nза раунд"
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
