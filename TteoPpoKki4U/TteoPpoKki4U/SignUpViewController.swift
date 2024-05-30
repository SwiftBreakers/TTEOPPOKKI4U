//
//  SignUpViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/30/24.
//

import UIKit
import SnapKit

class SignUpViewController: UIViewController {
    
    let nicknameLabel = UILabel()
    let nicknameTextField = UITextField()
    let nicknameErrorLabel = UILabel()
    
    let emailLabel = UILabel()
    let emailTextField = UITextField()
    let emailErrorLabel = UILabel()
    
    let passwordLabel = UILabel()
    let passwordTextField = UITextField()
    let passwordErrorLabel = UILabel()
    
    let confirmPasswordLabel = UILabel()
    let confirmPasswordTextField = UITextField()
    let confirmPasswordErrorLabel = UILabel()
    
    let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입하기", for: .normal)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(nil, action: #selector(signUpButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    let signVM = SignVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupLayout()
    }
    
    func setupUI() {
        // Label 설정
        nicknameLabel.text = "Nickname"
        emailLabel.text = "Email Address"
        passwordLabel.text = "Password"
        confirmPasswordLabel.text = "Confirm Password"
        
        // TextField 설정
        [nicknameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach { textField in
            textField.borderStyle = .roundedRect
            textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        }
        
        // Error Label 설정
        [nicknameErrorLabel, emailErrorLabel, passwordErrorLabel, confirmPasswordErrorLabel].forEach { label in
            label.text = "Can't leave field empty"
            label.textColor = .red
            label.font = UIFont.systemFont(ofSize: 12)
        }
        
        
        
        // View에 추가
        [nicknameLabel, nicknameTextField, nicknameErrorLabel,
         emailLabel, emailTextField, emailErrorLabel,
         passwordLabel, passwordTextField, passwordErrorLabel,
         confirmPasswordLabel, confirmPasswordTextField, confirmPasswordErrorLabel,
         signUpButton].forEach { subview in
            view.addSubview(subview)
        }
    }
    
    func setupLayout() {
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(nicknameLabel)
            make.height.equalTo(40)
        }
        
        nicknameErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(2)
            make.leading.trailing.equalTo(nicknameLabel)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameErrorLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(nicknameLabel)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(nicknameLabel)
            make.height.equalTo(40)
        }
        
        emailErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(2)
            make.leading.trailing.equalTo(nicknameLabel)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailErrorLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(nicknameLabel)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(nicknameLabel)
            make.height.equalTo(40)
        }
        
        passwordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(2)
            make.leading.trailing.equalTo(nicknameLabel)
        }
        
        confirmPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordErrorLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(nicknameLabel)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(nicknameLabel)
            make.height.equalTo(40)
        }
        
        confirmPasswordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(2)
            make.leading.trailing.equalTo(nicknameLabel)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordErrorLabel.snp.bottom).offset(20 * 2)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
    
    @objc func signUpButtonDidTapped() {
        
        signVM.signUp(nickName: nicknameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!) { [weak self] error in
            let alert = UIAlertController(title: "에러 발생", message: "\(error.localizedDescription)이 발생했습니다", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self?.present(alert, animated: true)
        }
        let alert = UIAlertController(title: "가입 완료", message: "회원 가입 되었습니다.\n환영합니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
}
