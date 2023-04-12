//
//  ViewController.swift
//  Neuroginarium
//
//  Created by Станислава on 31.01.2023.
//

import UIKit

class StartViewController: UIViewController {
    
    private lazy var titleLabel = UILabel()
    private lazy var findGameButton = UIButton()
    private lazy var gameWithFriendsButton = UIButton()
    private lazy var ratingButton = UIButton()
    private lazy var rulesButton = UIButton()
    
    private lazy var userService = UserService()
    private lazy var gameService = GameService()
    
    private lazy var userId = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        self.navigationItem.hidesBackButton = true
    }
    
    private func setupView() {
        let backgroundImage = UIImage(named: "back")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        backgroundImageView.frame = view.frame
        view.sendSubviewToBack(backgroundImageView)
        
        setupTitleLabel()
        setupFindGameButton()
        setupGameWithFriendsButton()
        setupRatingButton()
        setupRulesButton()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Нейроджинариум"
        titleLabel.textAlignment = .center
        titleLabel.textColor = Colors.white.uiColor
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupFindGameButton() {
        findGameButton.setTitle("НАЙТИ ИГРУ", for: .normal)
        findGameButton.backgroundColor = Colors.lightYellow.uiColor
        findGameButton.setTitleColor(Colors.darkBlue.uiColor, for: .normal)
        
        findGameButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        findGameButton.layer.borderColor = Colors.blue.uiColor.cgColor
        findGameButton.layer.borderWidth = 3
        
        findGameButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(findGameButton)
        
        NSLayoutConstraint.activate([
            findGameButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 70),
            findGameButton.heightAnchor.constraint(equalToConstant: 50),
            findGameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            findGameButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
        
        findGameButton.addTarget(self, action: #selector(findGameButtonTapped), for: .touchUpInside)
    }
    
    @objc func findGameButtonTapped() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.findGameButton.backgroundColor = Colors.blue.uiColor
        }, completion: { finished in
            UIView.animate(withDuration: 0.4, animations: {
                self.findGameButton.backgroundColor = Colors.lightYellow.uiColor
                
                self.gameService.findGame(userId: self.userId) { [weak self] result in
                    switch result {
                    case .success(let gameId):
                        print("Game ID: \(gameId)")
                        DispatchQueue.main.async {
                            let waitingRoomVC = WatingRoomViewController()
                            waitingRoomVC.configure(userId: self?.userId ?? 0, gameId: gameId)
                            self?.navigationController?.pushViewController(waitingRoomVC, animated: true)
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                        DispatchQueue.main.async {
                            self?.showAlert()
                        }
                    }
                }
            })
        })
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Ошибка соединения", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        let retryAction = UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.findGameButtonTapped()
        })
        
        alertController.addAction(okAction)
        alertController.addAction(retryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func setupGameWithFriendsButton() {
        gameWithFriendsButton.setTitle("ИГРАТЬ С ДРУЗЬЯМИ", for: .normal)
        gameWithFriendsButton.backgroundColor = Colors.lightYellow.uiColor
        gameWithFriendsButton.setTitleColor(Colors.darkBlue.uiColor, for: .normal)
        

        gameWithFriendsButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        gameWithFriendsButton.layer.borderColor = Colors.blue.uiColor.cgColor
        gameWithFriendsButton.layer.borderWidth = 3
        
        gameWithFriendsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameWithFriendsButton)
        
        NSLayoutConstraint.activate([
            gameWithFriendsButton.topAnchor.constraint(equalTo: findGameButton.bottomAnchor, constant: 20),
            gameWithFriendsButton.heightAnchor.constraint(equalToConstant: 50),
            gameWithFriendsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            gameWithFriendsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
        
        gameWithFriendsButton.addTarget(self, action: #selector(gameWithFriendsButtonTapped), for: .touchUpInside)
    }
    
    @objc func gameWithFriendsButtonTapped() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.gameWithFriendsButton.backgroundColor = Colors.blue.uiColor
        }, completion: { finished in
            UIView.animate(withDuration: 0.4, animations: {
                self.gameWithFriendsButton.backgroundColor = Colors.lightYellow.uiColor
                
                let gameWithFriendsVC = GameWithFriendsStartViewController()
                gameWithFriendsVC.configure(with: self.userId)
                self.navigationController?.pushViewController(gameWithFriendsVC, animated: true)
            })
        })
    }
    
    
    private func setupRatingButton() {
        ratingButton.setTitle("РЭЙТИНГ ИГРОКОВ", for: .normal)
        ratingButton.backgroundColor = Colors.lightOrange.uiColor
        ratingButton.setTitleColor(Colors.darkBlue.uiColor, for: .normal)
        

        ratingButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        ratingButton.layer.borderColor = Colors.pink.uiColor.cgColor
        ratingButton.layer.borderWidth = 4
        
        ratingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ratingButton)
        
        NSLayoutConstraint.activate([
            ratingButton.topAnchor.constraint(equalTo: gameWithFriendsButton.bottomAnchor, constant: 40),
            ratingButton.heightAnchor.constraint(equalToConstant: 50),
            ratingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            ratingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
        
        ratingButton.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
    }
    
    func configure(with userId: Int) {
        self.userId = userId
    }
    
    @objc func ratingButtonTapped() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.ratingButton.backgroundColor = Colors.lightPink.uiColor
        }, completion: { finished in
            UIView.animate(withDuration: 0.4, animations: {
                self.ratingButton.backgroundColor = Colors.lightOrange.uiColor
                
                let ratingVC = RatingViewController()
                ratingVC.configure(with: self.userId)
                self.navigationController?.pushViewController(ratingVC, animated: true)
            })
        })
    }
    
    private func setupRulesButton() {
        rulesButton.setTitle("ПРАВИЛА ИГРЫ", for: .normal)
        rulesButton.backgroundColor = Colors.lightOrange.uiColor
        rulesButton.setTitleColor(Colors.darkBlue.uiColor, for: .normal)
    
        rulesButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        rulesButton.layer.borderColor = Colors.pink.uiColor.cgColor
        rulesButton.layer.borderWidth = 4
        
        rulesButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rulesButton)
        
        NSLayoutConstraint.activate([
            rulesButton.topAnchor.constraint(equalTo: ratingButton.bottomAnchor, constant: 20),
            rulesButton.heightAnchor.constraint(equalToConstant: 50),
            rulesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            rulesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
        
        rulesButton.addTarget(self, action: #selector(rulesButtonTapped), for: .touchUpInside)
    }
    
    @objc func rulesButtonTapped() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.rulesButton.backgroundColor = Colors.lightPink.uiColor
        }, completion: { finished in
            UIView.animate(withDuration: 0.4, animations: {
                self.rulesButton.backgroundColor = Colors.lightOrange.uiColor
                self.present(RulesViewController(), animated: true)
            })
        })
    }

}

