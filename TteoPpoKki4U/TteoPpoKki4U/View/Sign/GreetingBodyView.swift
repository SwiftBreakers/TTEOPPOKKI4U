//
//  GreetingBodyView.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/31/24.
//

import UIKit
import SnapKit
import AuthenticationServices
import KakaoSDKAuth
import GoogleSignIn

class GreetingBodyView: UIView {
    
    lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.cornerRadius = 25
        button.addTarget(self, action: #selector(appleButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(kakaoButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(googleButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    var appleTapped: (() -> Void)?
    var kakaoTapped: (() -> Void)?
    var googleTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        [appleLoginButton, kakaoLoginButton, googleLoginButton].forEach { button in
            self.addSubview(button)
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.leading.trailing.height.equalTo(50)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.top.equalTo(appleLoginButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.leading.trailing.height.equalTo(50)
        }
        
        googleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(kakaoLoginButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.leading.trailing.height.equalTo(50)
        }
        
    }
    
    @objc func appleButtonDidTapped() {
        appleTapped?()
    }
    
    @objc func kakaoButtonDidTapped() {
        kakaoTapped?()
    }
    
    @objc func googleButtonDidTapped() {
        googleTapped?()
    }
    
}
