//
//  CheckCodeViewController.swift
//  Neuroginarium
//
//  Created by Станислава on 02.04.2023.
//

import UIKit

class CheckCodeViewController: UIViewController {
    
    let titleLabel = UILabel()
    let tokenTextField = UITextField()
    let confirmButton = UIButton()
    let errorLabel = UILabel()
    
    private lazy var userService = UserService()
    private lazy var email = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTitleLabel()
        setupTokenTextField()
        setupRegisterButton()
        setupErrorLabel()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Подтверждение почты"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupErrorLabel() {
        errorLabel.text = "Неверный код"
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.bottomAnchor.constraint(equalTo: tokenTextField.topAnchor, constant: -16),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        errorLabel.isHidden = true
    }
    
    private func setupTokenTextField() {
        tokenTextField.placeholder = "Введите код подтверждения"
        tokenTextField.borderStyle = .roundedRect
        tokenTextField.autocorrectionType = .no
        view.addSubview(tokenTextField)
        tokenTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tokenTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            tokenTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tokenTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tokenTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        tokenTextField.delegate = self
    }
    
    private func setupRegisterButton() {
        confirmButton.setTitle("Подтвердить", for: .normal)
        confirmButton.backgroundColor = UIColor.systemBlue
        confirmButton.layer.cornerRadius = 8
        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: tokenTextField.bottomAnchor, constant: 20),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    func configure(with email: String) {
        self.email = email
        print(email)
        print(self.email)
    }
    
    @objc func confirmButtonTapped() {
        userService.checkEmailConfirmationToken(token: tokenTextField.text ?? "", email: self.email) { [weak self] result in
            switch result {
            case .success:
                print("Email confirmed successfully")
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(LoginViewController(), animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorLabel.isHidden = false
                }
                print("Failed to confirm email: \(error.localizedDescription)")
            }
        }
    }
    
}

extension CheckCodeViewController: UITextFieldDelegate {
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

