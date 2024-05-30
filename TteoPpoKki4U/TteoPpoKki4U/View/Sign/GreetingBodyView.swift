//
//  GreetingBodyView.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/31/24.
//

import UIKit
import SnapKit

class GreetingBodyView: UIView {
    
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = UIColor.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(nil, action: #selector(signInDidTapped), for: .touchUpInside)
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up with Email", for: .normal)
        button.backgroundColor = UIColor.green
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(nil, action: #selector(signUpDidTapped), for: .touchUpInside)
        return button
    }()
    
    let appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apple", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 25
        button.setImage(UIImage(systemName: "applelogo"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let kakaoLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("카카오 로그인", for: .normal)
        button.backgroundColor = UIColor.yellow
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 25
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let naverLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("네이버 로그인", for: .normal)
        button.backgroundColor = UIColor.green
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.setImage(UIImage(systemName: "n.square.fill"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Google", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.gray, for: .normal)
        button.layer.cornerRadius = 25
        button.setImage(UIImage(named: "google"), for: .normal) // 구글 로고 이미지 추가
        button.tintColor = .gray
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        [signInButton, signUpButton, appleLoginButton, kakaoLoginButton, naverLoginButton, googleLoginButton].forEach { button in
            self.addSubview(button)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.leading.trailing.height.equalTo(50)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.leading.trailing.height.equalTo(signInButton)
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.leading.trailing.height.equalTo(signInButton)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.top.equalTo(appleLoginButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.leading.trailing.height.equalTo(signInButton)
        }
        
        naverLoginButton.snp.makeConstraints { make in
            make.top.equalTo(kakaoLoginButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.leading.trailing.height.equalTo(signInButton)
        }
        
        googleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(naverLoginButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.leading.trailing.height.equalTo(signInButton)
        }
        
    }
    
    
    
    @objc func signUpDidTapped() {
        let signUpVC = SignUpViewController()
        currentViewController!.present(signUpVC, animated: true)
    }
    
    @objc func signInDidTapped() {
        let signInVC = SignInViewController()
        currentViewController!.present(signInVC, animated: true)
    }
    
}

extension UIResponder {
    var currentViewController: UIViewController? {
        return next as? UIViewController ?? next?.currentViewController
    }
}
