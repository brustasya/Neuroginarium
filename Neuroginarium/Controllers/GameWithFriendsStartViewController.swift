//
//  GameWithFriendsStartViewController.swift
//  Neuroginarium
//
//  Created by Станислава on 02.04.2023.
//

import UIKit

class GameWithFriendsStartViewController: UIViewController {
    
    private lazy var userId = 0
    private lazy var gameService = GameService()
    
    let tokenTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите код игры"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = Colors.lightOrange.uiColor
        tf.font = .systemFont(ofSize: 20)
        tf.layer.borderColor = Colors.pink.uiColor.cgColor
        tf.layer.borderWidth = 3
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = .no
        tf.layer.cornerRadius = 5
        return tf
    }()
    
    let createGameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать новую игру", for: .normal)
        button.setTitleColor(Colors.darkBlue.uiColor, for: .normal)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.layer.borderColor = Colors.darkBlue.uiColor.cgColor
        button.layer.borderWidth = 3
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Неверный токен"
        label.textColor = UIColor.red
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "back")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        backgroundImageView.frame = view.frame
        view.sendSubviewToBack(backgroundImageView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .done,
            target: self,
            action: #selector(goBack)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        setupTokenTextField()
        setupCreateGameButton()
        setupErrorLabel()
    }
    
    @objc private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTokenTextField() {
        view.addSubview(tokenTextField)
        
        NSLayoutConstraint.activate([
            tokenTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            tokenTextField.heightAnchor.constraint(equalToConstant: 50),
            tokenTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            tokenTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80)
        ])
        
       let connectButton = UIButton(type: .system)
        connectButton.setImage(UIImage(
            systemName: "arrow.right.square.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)),
            for: .normal
        )
        view.addSubview(connectButton)
        connectButton.tintColor = Colors.pink.uiColor
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            connectButton.widthAnchor.constraint(equalToConstant: 50),
            connectButton.leadingAnchor.constraint(equalTo: tokenTextField.trailingAnchor),
            connectButton.topAnchor.constraint(equalTo: tokenTextField.topAnchor),
            connectButton.bottomAnchor.constraint(equalTo: tokenTextField.bottomAnchor)
        ])
        
        connectButton.addTarget(self, action: #selector(joinGame), for: .touchUpInside)
        
        tokenTextField.delegate = self
    }
    
    private func setupCreateGameButton() {
        view.addSubview(createGameButton)
        
        NSLayoutConstraint.activate([
            createGameButton.heightAnchor.constraint(equalToConstant: 50),
            createGameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            createGameButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            createGameButton.topAnchor.constraint(equalTo: tokenTextField.bottomAnchor, constant: 16)
        ])
        
        createGameButton.addTarget(self, action: #selector(createGameButtonTapped), for: .touchUpInside)
    }
    
    private func setupErrorLabel() {
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.bottomAnchor.constraint(equalTo: tokenTextField.topAnchor, constant: -8),
            errorLabel.leadingAnchor.constraint(equalTo: tokenTextField.leadingAnchor, constant: 5)
        ])
        
        errorLabel.isHidden = true
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
    
    private func createGame() {
        gameService.createGame(userId: self.userId) { [weak self] result in
            switch result {
            case .success(let response):
                print("Game created with gameId: \(response.gameId) and gameToken: \(response.gameToken)")
                
                DispatchQueue.main.async {
                    let watingRoomVc = WatingRoomViewController()
                    watingRoomVc.configure(
                        userId: self?.userId ?? 0,
                        gameId: response.gameId,
                        token: response.gameToken,
                        isCreator: true
                    )
                    self?.navigationController?.pushViewController(watingRoomVc, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert()
                }
                print("Error creating game: \(error.localizedDescription)")
            }
        }
    }
    
    func configure(with userId: Int) {
        self.userId = userId
    }
    
    @objc private func createGameButtonTapped() {
        UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
            self.createGameButton.backgroundColor = Colors.blue.uiColor
        }, completion: { finished in
            UIView.animate(withDuration: 0.4, animations: {
                self.createGameButton.backgroundColor = UIColor.clear
                
                self.createGame()
            })
        })
    }
    
    @objc private func joinGame() {
        gameService.joinGame(userId: self.userId, gameToken: self.tokenTextField.text ?? "") { [weak self] result in
            switch result {
            case .success(let gameId):
                print("Successfully joined game with id \(gameId)")
                
                DispatchQueue.main.async {
                    let watingRoomVc = WatingRoomViewController()
                    watingRoomVc.configure(
                        userId: self?.userId ?? 0,
                        gameId: gameId,
                        token: self?.tokenTextField.text ?? "",
                        isCreator: false
                    )
                    self?.navigationController?.pushViewController(watingRoomVc, animated: true)
                    self?.errorLabel.isHidden = true
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorLabel.isHidden = false
                }
                print("Error joining game: \(error.localizedDescription)")
            }
        }
    }
}


extension GameWithFriendsStartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}
