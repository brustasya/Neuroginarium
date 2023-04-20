//
//  EnterViewController.swift
//  Neuroginarium
//
//  Created by Станислава on 02.04.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    let titleLabel = UILabel()
    let loginTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton()
    let registerButton = UIButton(type: .system)
    let errorLabel = UILabel()
    
    private lazy var userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.hidesBackButton = true

        setupTitleLabel()
        setupLoginTextField()
        setupPasswordTextField()
        setupLoginButton()
        setupRegisterButton()
        setupErrorLabel()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Вход"
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
        errorLabel.text = "Неверный логин или пароль"
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
    
    private func setupPasswordTextField() {
        passwordTextField.placeholder = "Пароль"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        passwordTextField.delegate = self
    }
    
    private func setupLoginButton() {
        loginButton.setTitle("Войти", for: .normal)
        loginButton.backgroundColor = UIColor.systemBlue
        loginButton.layer.cornerRadius = 8
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    private func setupRegisterButton() {
        registerButton.setTitle("Еще не зарегистрированы?", for: .normal)
        registerButton.setTitleColor(UIColor.systemBlue, for: .normal)
        view.addSubview(registerButton)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    @objc func loginButtonTapped() {
        userService.authorize(nickname: loginTextField.text ?? "", password: passwordTextField.text ?? "") { [weak self] (result) in
            switch result {
            case .success(let userInfo):
                print("Authorized user with ID \(userInfo.userId)")
                DispatchQueue.main.async {
                    let startVC = StartViewController()
                    startVC.configure(with: userInfo.userId)
                    self?.navigationController?.pushViewController(startVC, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorLabel.isHidden = false
                }
                
                print("Authorization failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func registerButtonTapped() {
        navigationController?.pushViewController(RegistrationViewController(), animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
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
