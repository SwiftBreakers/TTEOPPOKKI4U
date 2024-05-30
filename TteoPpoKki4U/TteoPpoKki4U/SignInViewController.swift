//
//  ViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import SnapKit

class SignInViewController: UIViewController {
    
   
    // UI 요소 생성
    let emailLabel = UILabel()
    let emailTextField = UITextField()
    let emailErrorLabel = UILabel()
    
    let passwordLabel = UILabel()
    let passwordTextField = UITextField()
    let passwordErrorLabel = UILabel()
    
    let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(nil, action: #selector(signInButtonDidTapped), for: .touchUpInside)
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
        emailLabel.text = "Email Address"
        passwordLabel.text = "Password"
        
        // TextField 설정
        [emailTextField, passwordTextField].forEach { textField in
            textField.borderStyle = .roundedRect
            textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        }
        
        // Error Label 설정
        [emailErrorLabel, passwordErrorLabel].forEach { label in
            label.text = "Can't leave field empty"
            label.textColor = .red
            label.font = UIFont.systemFont(ofSize: 12)
        }
        
        
        // View에 추가
        [emailLabel, emailTextField, emailErrorLabel,
         passwordLabel, passwordTextField, passwordErrorLabel,
         signInButton].forEach { view.addSubview($0) }
    }
    
    func setupLayout() {
        let padding: CGFloat = 20
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
            make.leading.equalTo(view).offset(padding)
            make.trailing.equalTo(view).offset(-padding)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(emailLabel)
            make.height.equalTo(40)
        }
        
        emailErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(2)
            make.leading.trailing.equalTo(emailLabel)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailErrorLabel.snp.bottom).offset(padding)
            make.leading.trailing.equalTo(emailLabel)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(emailLabel)
            make.height.equalTo(40)
        }
        
        passwordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(2)
            make.leading.trailing.equalTo(emailLabel)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(passwordErrorLabel.snp.bottom).offset(padding * 2)
            make.leading.equalTo(view).offset(padding)
            make.trailing.equalTo(view).offset(-padding)
            make.height.equalTo(50)
        }
    }
    
    @objc func signInButtonDidTapped() {
        signVM.signIn(email: emailTextField.text!, password: passwordTextField.text!) { [weak self] error in
            let alert = UIAlertController(title: "에러 발생", message: "\(error.localizedDescription)이 발생했습니다", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

