//
//  WatingRoomViewController.swift
//  Neuroginarium
//
//  Created by Станислава on 02.04.2023.
//

import UIKit

class WatingRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var userService = UserService()
    private lazy var gameService = GameService()
    
    private lazy var userId = 0
    private lazy var gameId = 0
    
    private lazy var isGameStarted = false
    private lazy var token = ""
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Комната ожидания"
        label.textColor = Colors.white.uiColor
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let tokenLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.white.uiColor
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let startGameButton: UIButton = {
        let button = UIButton()
        button.setTitle("НАЧАТЬ ИГРУ", for: .normal)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(Colors.lightOrange.uiColor, for: .normal)
        
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.layer.borderColor = Colors.lightOrange.uiColor.cgColor
        button.layer.borderWidth = 4
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let playersTable = UITableView()

    private lazy var players: [PlayerDto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.titleView = titleLabel
        self.navigationItem.hidesBackButton = true

        let backgroundImage = UIImage(named: "back")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        backgroundImageView.frame = view.frame
        view.sendSubviewToBack(backgroundImageView)
        
        setupTokenLabel()
        setupStartGameButton()
        setupPlayersTable()
    }
    
    private func setupPlayersTable() {
        playersTable.delegate = self
        playersTable.dataSource = self
        playersTable.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")
        view.addSubview(playersTable)
        
        playersTable.separatorStyle = .none
        playersTable.backgroundColor = UIColor.clear
        playersTable.allowsSelection = false
        playersTable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playersTable.topAnchor.constraint(equalTo: tokenLabel.bottomAnchor, constant: 16),
            playersTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playersTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playersTable.bottomAnchor.constraint(equalTo: startGameButton.topAnchor, constant: -16)
        ])
    }
    
    private func setupStartGameButton() {
        view.addSubview(startGameButton)
        
        NSLayoutConstraint.activate([
            startGameButton.heightAnchor.constraint(equalToConstant: 40),
            startGameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            startGameButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            startGameButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        startGameButton.addTarget(self, action: #selector(startGameButtonTapped), for: .touchUpInside)
    }
    
    private func setupTokenLabel() {
        view.addSubview(tokenLabel)
        
        NSLayoutConstraint.activate([
            tokenLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tokenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        cell.textLabel?.text = players[indexPath.row].nickname
        cell.backgroundColor = Colors.white.uiColor
        return cell
    }
    
    func configure(userId: Int, gameId: Int) {
        self.userId = userId
        self.gameId = gameId
        
        startGameButton.isHidden = true
        tokenLabel.isHidden = true
        
        loadPlayers()
        startGame()
    }
    
    func configure(userId: Int, gameId: Int, token: String, isCreator: Bool) {
        self.userId = userId
        self.gameId = gameId
        self.token = token
        tokenLabel.text = "Код для подключения:\n\(token)"
        
        loadPlayers()

        if !isCreator {
            startGameButton.isHidden = true
            startGame()
        }
    }
    
    private func loadPlayers() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.gameService.getPlayers(id: self?.gameId ?? 0) { [weak self] result in
                switch result {
                case .success(let players):
                    DispatchQueue.main.async {
                        self?.players = players
                        self?.playersTable.reloadData()
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
                if !(self?.isGameStarted ?? false) {
                    self?.loadPlayers()
                }
            }
        }
    }
    
    private func startGame() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            if !(self?.isGameStarted ?? false) {
                self?.gameService.getGame(id: self?.gameId ?? 0) { [weak self]  result in
                    switch result {
                    case .success(let gameDto):
                        print(gameDto)
                        if (gameDto.isGameStarted) {
                            DispatchQueue.main.async {
                                self?.isGameStarted = true
                                let gameVC = GameViewController()
                                gameVC.configure(self?.gameId ?? 0, self?.userId ?? 0)
                                self?.navigationController?.pushViewController(gameVC, animated: true)
                                return
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            if !(self?.isGameStarted ?? false) {
                self?.startGame()
            }
        }
    }
    
    private func createGame() {
        gameService.startGame(gameToken: self.token) { [weak self] result in
            switch result {
            case .success(let responseString):
                print("Request succeeded with response: \(responseString)")
                DispatchQueue.main.async {
                    self?.isGameStarted = true
                    let gameVC = GameViewController()
                    gameVC.configure(self?.gameId ?? 0, self?.userId ?? 0)
                    self?.navigationController?.pushViewController(gameVC, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert()
                }
                print("Request failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Ошибка соединения", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        let retryAction = UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.createGame()
        })
        
        alertController.addAction(okAction)
        alertController.addAction(retryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    @objc private func startGameButtonTapped() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.startGameButton.backgroundColor = Colors.darkBlue.uiColor
        }, completion: { finished in
            UIView.animate(withDuration: 0.4, animations: {
                self.startGameButton.backgroundColor = UIColor.clear
                self.createGame()
            })
        })
    }
}
