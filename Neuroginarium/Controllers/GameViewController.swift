//
//  GameViewController2.swift
//  Neuroginarium
//
//  Created by Станислава on 29.03.2023.
//

import UIKit


class GameViewController: UIViewController {

    // MARK: - Properties
    
    let scrollView = UIScrollView()
    let pageControl = UIPageControl()
    
    private var cards: [CardDto] = []
    
    private lazy var userId = 0
    private lazy var gameId = 0
    private lazy var roundId = 0
    
    private lazy var isRoundContinue = true
    
    private lazy var gameService = GameService()
    private lazy var userService = UserService()
    
    var currentPage: Int = 0
    var isKeyboardVisible = false
    var indexOfSelectedCard = -1
    private lazy var isImageSelectedEnable = false
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let associationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите ассоциацию"
        tf.borderStyle = .roundedRect
        tf.autocorrectionType = .default
        return tf
    }()
    
    let associatedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        label.backgroundColor = Colors.darkBlue.uiColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отправить", for: .normal)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(Colors.lightOrange.uiColor, for: .normal)
        
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.borderColor = Colors.lightOrange.uiColor.cgColor
        button.layer.borderWidth = 3
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let choosedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Выбрать", for: .normal)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(Colors.lightOrange.uiColor, for: .normal)
        
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.borderColor = Colors.lightOrange.uiColor.cgColor
        button.layer.borderWidth = 3
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let voteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Проголосовать", for: .normal)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(Colors.lightOrange.uiColor, for: .normal)
        
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.borderColor = Colors.lightOrange.uiColor.cgColor
        button.layer.borderWidth = 3
        
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
        
        self.navigationItem.hidesBackButton = true
        
        setupScrollView()
        setupPageControl()
        setupSendButton()
        setupVoteButton()
        setupChooseButton()
        setupAssociationLabel()
        setupAssociationTextField()
        
        addTapGesture()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        associationTextField.frame = CGRect(x: 16, y: pageControl.frame.maxY + 16, width: view.frame.width - 32, height: 40)
        
    }
    
    private func setupSendButton() {
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])

        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.isHidden = true
    }
    
    private func setupChooseButton() {
        view.addSubview(choosedButton)
        
        NSLayoutConstraint.activate([
            choosedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            choosedButton.heightAnchor.constraint(equalToConstant: 40),
            choosedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            choosedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])

        choosedButton.addTarget(self, action: #selector(choosedButtonTapped), for: .touchUpInside)
        choosedButton.isHidden = true
    }
    
    private func setupVoteButton() {
        view.addSubview(voteButton)
        
        NSLayoutConstraint.activate([
            voteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            voteButton.heightAnchor.constraint(equalToConstant: 40),
            voteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            voteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])

        voteButton.addTarget(self, action: #selector(voteButtonTapped), for: .touchUpInside)
        voteButton.isHidden = true
    }
    
    private func setupAssociationTextField() {
        view.addSubview(associationTextField)

        associationTextField.delegate = self
        associationTextField.isHidden = true
    }
    
    private func setupAssociationLabel() {
        view.addSubview(associatedLabel)
        
        NSLayoutConstraint.activate([
            associatedLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 32),
            associatedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            associatedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            associatedLabel.bottomAnchor.constraint(lessThanOrEqualTo: sendButton.topAnchor, constant: -16),
        ])
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
        
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        )?.cgRectValue.size else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.associationTextField.frame.origin.y = self.view.frame.size.height -
            keyboardSize.height - self.associationTextField.frame.size.height - 8
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1) {
            self.associationTextField.frame.origin.y = self.pageControl.frame.maxY + 16
        }
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.7/3),
        ])
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func loadImages() {
        var previousImageView: UIImageView?
        for (index, image) in cards.enumerated() {
            let imageView = UIImageView(image: decodeImage(from: image.image))
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = Colors.darkBlue.uiColor
            imageView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
                imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.7/3),
            ])
            
            if let previousImageView = previousImageView {
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: previousImageView.trailingAnchor),
                ])
            } else {
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                ])
            }
            
            if index == cards.count - 1 {
                NSLayoutConstraint.activate([
                    imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                ])
            }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGesture)
            previousImageView = imageView
        }
        
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(cards.count), height: view.frame.height)
        currentPage = 0
        pageControl.numberOfPages = cards.count
        pageControl.currentPage = currentPage
        imageView.image = decodeImage(from: cards[currentPage].image)
        imageView.backgroundColor = Colors.darkBlue.uiColor
        
        pageControl.numberOfPages = cards.count
        pageControl.currentPage = currentPage
    }
    
    private func setupChoiceAssociationView(_ isLeading: Bool) {
        navigationItem.titleView = titleLabel
        titleLabel.text = "Ход ведущего"
        
        if isLeading {
            isImageSelectedEnable = true
            sendButton.isHidden = false
            associationTextField.isHidden = false
        } else {
            isImageSelectedEnable = false
            associatedLabel.text = "Ожидайте, пока ведущий загадает\nкарточку с ассоциацией"
            associatedLabel.isHidden = false
            associationTextField.isHidden = true
            transitionToCardChoice()
        }
        
        gameService.getPlayerCards(gameId: gameId, userId: userId) { [weak self] result in
            switch result {
            case .success(let cards):
                DispatchQueue.main.async {
                    self?.cards = cards
                    self?.loadImages()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func setupAssociationGivenView(_ isLeading: Bool, _ association: String) {
        navigationItem.titleView = titleLabel
        titleLabel.text = "Выбор карты по ассоциации"
        
        if isLeading {
            isImageSelectedEnable = false
            associatedLabel.text = "Ожидайте, пока игроки выберут карточки"
            associatedLabel.isHidden = false
            associationTextField.isHidden = true
            transitionToVoting()
        } else {
            isImageSelectedEnable = true
            choosedButton.isHidden = false
            associatedLabel.isHidden = false
            associatedLabel.text = "Загаданная ассоциация:\n\(association)"
            associationTextField.isHidden = true
        }
        
        gameService.getPlayerCards(gameId: gameId, userId: userId) { [weak self] result in
            switch result {
            case .success(let cards):
                DispatchQueue.main.async {
                    print("load cards")
                    self?.cards = cards
                    self?.loadImages()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func setupVotingView(_ isLeading: Bool, _ association: String) {
        navigationItem.titleView = titleLabel
        titleLabel.text = "Голосование"
        
        if isLeading {
            isImageSelectedEnable = false
            associatedLabel.text = "Ожидайте, пока игроки проголосуют"
            associatedLabel.isHidden = false
            associationTextField.isHidden = true
            presentResults()

        } else {
            isImageSelectedEnable = true
            voteButton.isHidden = false
            associatedLabel.isHidden = false
            associatedLabel.text = "Загаданная ассоциация:\n\(association)" 
            associationTextField.isHidden = true
        }
        
        gameService.getCardsOnTable(id: gameId) { [weak self] result in
            switch result {
            case .success(let cards):
                DispatchQueue.main.async {
                    print("load cards")
                    self?.cards = cards
                    self?.loadImages()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func transitionToCardChoice() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if self?.isRoundContinue ?? true {
                self?.gameService.getCurrentRound(id: self?.gameId ?? 0) { [weak self] result in
                    switch result {
                    case .success(let round):
                        if round.status == .associationGiven {
                            DispatchQueue.main.async {
                                self?.isRoundContinue = false
                                let gameVC = GameViewController()
                                gameVC.configure(self?.gameId ?? 0, self?.userId ?? 0)
                                
                                self?.navigationController?.pushViewController(gameVC, animated: true)
                            }
                            return
                        }
                    case .failure(let error):
                        print("Error occurred while fetching current round: \(error.localizedDescription)")
                    }
                }
                
                if self?.isRoundContinue ?? true {
                    self?.transitionToCardChoice()
                }
            }
        }
    }
    
    private func transitionToVoting() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if self?.isRoundContinue ?? true {
                self?.gameService.getCurrentRound(id: self?.gameId ?? 0) { [weak self] result in
                    switch result {
                    case .success(let round):
                        print(round)
                        if round.status == .votingStarted {
                            DispatchQueue.main.async {
                                self?.isRoundContinue = false
                                let gameVC = GameViewController()
                                gameVC.configure(self?.gameId ?? 0, self?.userId ?? 0)
                                
                                self?.navigationController?.pushViewController(gameVC, animated: true)
                            }
                            return
                        }
                    case .failure(let error):
                        print("Error occurred while fetching current round: \(error.localizedDescription)")
                    }
                }
                if self?.isRoundContinue ?? true {
                    self?.transitionToVoting()
                }
            }
        }
    }
    
    private func presentResults() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if self?.isRoundContinue ?? true {
                self?.gameService.getRound(roundId: self?.roundId ?? 0) { [weak self] result in
                    switch result {
                    case .success(let round):
                        print(round)
                        if round.status == .votingMade {
                            DispatchQueue.main.async {
                                self?.isRoundContinue = false
                                let resultsVC = ResultsViewController()
                                resultsVC.configure(self?.gameId ?? 0, self?.userId ?? 0, self?.roundId ?? 0)
                                self?.navigationController?.pushViewController(resultsVC, animated: true)
                            }
                            return
                        }
                    case .failure(let error):
                        print("Error occurred while fetching current round: \(error.localizedDescription)")
                    }
                }
                if self?.isRoundContinue ?? true {
                    self?.presentResults()
                }
            }
        }
    }
    
    private func decodeImage(from base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            print("nil")
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    private func getRoundInfo() {
        gameService.getCurrentRound(id: gameId) { [weak self] result in
            switch result {
            case .success(let round):
                print(round)
                DispatchQueue.main.async {
                    self?.roundId = round.id
                    
                    switch(round.status) {
                    case .started:
                        self?.setupChoiceAssociationView(round.associationCreatorUserId == self?.userId)
                        break
                    case .associationGiven:
                        self?.setupAssociationGivenView(round.associationCreatorUserId == self?.userId, round.association ?? "")
                        break
                    case .votingStarted:
                        self?.setupVotingView(round.associationCreatorUserId == self?.userId, round.association ?? "")
                        break
                    case .votingMade:
                        break
                    }
                    return
                }
            case .failure(let error):
                print("Error occurred while fetching current round: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - public Methods

    func configure(_ gameId: Int, _ userId: Int) {
        self.gameId = gameId
        self.userId = userId
        getRoundInfo()
    }
    
    // MARK: - @objc Methods
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if isImageSelectedEnable {
            guard let imageView = sender.view as? UIImageView,
                  let index = scrollView.subviews.firstIndex(of: imageView) else {
                return
            }
            
            for subview in scrollView.subviews {
                guard let imageView = subview as? UIImageView else {
                    continue
                }
                imageView.layer.borderWidth = 0
            }
            
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = Colors.lightOrange.uiColor.cgColor
            
            indexOfSelectedCard = index
        }
    }
    
    @objc func sendButtonTapped() {
        if indexOfSelectedCard != -1 && associationTextField.text != "" {
            UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                self.sendButton.backgroundColor = Colors.darkBlue.uiColor
            }, completion: { finished in
                UIView.animate(withDuration: 0.4, animations: {
                    self.sendButton.backgroundColor = UIColor.clear
                    self.gameService.giveAssociation(
                        roundId: self.roundId,
                        association: self.associationTextField.text ?? "",
                        cardId: self.cards[self.indexOfSelectedCard].id
                    ) { [weak self] result in
                        switch result {
                        case .success:
                            print("Association given successfully")
                            DispatchQueue.main.async {
                                let gameVC = GameViewController()
                                gameVC.configure(self?.gameId ?? 0, self?.userId ?? 0)
                                self?.navigationController?.pushViewController(gameVC, animated: true)
                            }
                        case .failure(let error):
                            print("Error giving association: \(error.localizedDescription)")
                        }
                    }
                })
            })
        }
    }
    
    
    @objc func choosedButtonTapped() {
        if indexOfSelectedCard != -1 {
            UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                self.choosedButton.backgroundColor = Colors.darkBlue.uiColor
            }, completion: { finished in
                UIView.animate(withDuration: 0.4, animations: {
                    self.choosedButton.backgroundColor = UIColor.clear
                    
                    self.gameService.giveCard(roundId: self.roundId, cardId: self.cards[self.indexOfSelectedCard].id) { [weak self] result in
                        switch result {
                        case .success:
                            print("Карта успешно передана в колоду!")
                            DispatchQueue.main.async {
                                self?.isImageSelectedEnable = false
                                self?.associatedLabel.text = "Ожидайте, пока остальные\nигроки выберут карточки"
                                self?.choosedButton.isEnabled = false
                            }
                            self?.transitionToVoting()
                        case .failure(let error):
                            print("Ошибка при передаче карты в колоду: \(error.localizedDescription)")
                        }
                    }
                    
                })
            })
        }
    }
        
    @objc func voteButtonTapped() {
        if indexOfSelectedCard != -1 {
            UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
                self.voteButton.backgroundColor = Colors.darkBlue.uiColor
                
            }, completion: { finished in
                UIView.animate(withDuration: 0.4, animations: {
                    self.voteButton.backgroundColor = UIColor.clear
                    
                    self.gameService.vote(roundId: self.roundId, userId: self.userId, cardId: self.cards[self.indexOfSelectedCard].id) { [weak self] result in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                self?.isImageSelectedEnable = false
                                self?.associatedLabel.text = "Ожидайте, пока остальные\nигроки проголосуют"
                                self?.choosedButton.isEnabled = false
                            }
                            
                            self?.presentResults()
                        case .failure(let error):
                            print("Ошибка при голосовании: \(error.localizedDescription)")
                        }
                    }
                })
            })
        }
    }
    
    @objc func pageControlTapped() {
        currentPage = pageControl.currentPage
        imageView.image = decodeImage(from: cards[currentPage].image)
    }
}

// MARK: - UIScrollViewDelegate

extension GameViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = currentPage
        imageView.image = decodeImage(from: cards[currentPage].image)
    }
}

extension GameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self, action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tapGesture)
    }
}
