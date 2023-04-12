//
//  RegistrationViewController.swift
//  Neuroginarium
//
//  Created by Станислава on 02.04.2023.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    let titleLabel = UILabel()
    let emailTextField = UITextField()
    let loginTextField = UITextField()
    let passwordTextField = UITextField()
    let registerButton = UIButton()
    let errorLabel = UILabel()
    
    private lazy var userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTitleLabel()
        setupLoginTextField()
        setupEmailTextField()
        setupPasswordTextField()
        setupRegisterButton()
        setupErrorLabel()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Регистрация"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
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
        errorLabel.text = "Логин уже существует"
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            //errorLabel.leadingAnchor.constraint(equalTo: loginTextField.leadingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: loginTextField.topAnchor, constant: -16),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        errorLabel.isHidden = true
    }
    
    private func setupLoginTextField() {
        loginTextField.placeholder = "Логин"
        loginTextField.borderStyle = .roundedRect
        loginTextField.autocorrectionType = .no
        view.addSubview(loginTextField)
        loginTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        loginTextField.delegate = self
    }
    
    private func setupEmailTextField() {
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocorrectionType = .no
        view.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        emailTextField.delegate = self
    }
    
    private func setupPasswordTextField() {
        passwordTextField.placeholder = "Пароль"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        passwordTextField.delegate = self
    }
    
    private func setupRegisterButton() {
        registerButton.setTitle("Зарегистрироваться", for: .normal)
        registerButton.backgroundColor = UIColor.systemBlue
        registerButton.layer.cornerRadius = 8
        view.addSubview(registerButton)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
   
    @objc func registerButtonTapped() {
        var isCorrect = true
        if loginTextField.text == "" {
            loginTextField.layer.borderColor = UIColor.red.cgColor
            loginTextField.layer.borderWidth = 0.5
            isCorrect = false
        }
        
        if emailTextField.text == "" {
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailTextField.layer.borderWidth = 0.5
            isCorrect = false
        }
        
        if passwordTextField.text == "" {
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            passwordTextField.layer.borderWidth = 0.5
            isCorrect = false
        }
        
        if isCorrect {
            let createUserDto = CreateUserDto(
                nickname: loginTextField.text ?? "",
                password: passwordTextField.text ?? "",
                email: emailTextField.text ?? ""
            )
            
            userService.addUser(createUserDto: createUserDto) { [weak self] result in
                switch result {
                case .success:
                    print("User successfully created!")
                    self?.userService.sendEmailConfirmation(for: createUserDto.email) { [weak self] result in
                        switch result {
                        case .success:
                            print("Email confirmation token sent successfully.")
                            DispatchQueue.main.async {
                                let checkCodeVC = CheckCodeViewController()
                                checkCodeVC.configure(with: createUserDto.email)
                                self?.navigationController?.pushViewController(checkCodeVC, animated: true)
                                self?.errorLabel.isHidden = true
                            }
                        case .failure(let error):
                            print("Error sending email confirmation token: \(error.localizedDescription)")
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorLabel.text = "Логин уже существует"
                        self?.errorLabel.isHidden = false
                    }
                    print("Error creating user: \(error.localizedDescription)")
                }
            }
        } else {
            errorLabel.text = "Не все данные введены"
            errorLabel.isHidden = false
        }
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
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

