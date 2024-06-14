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
    
    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(self, action: #selector(appleButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.addTarget(self, action: #selector(googleButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    var appleTapped: (() -> Void)?
    var googleTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        [appleLoginButton, googleLoginButton].forEach { button in
            self.addSubview(button)
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
            
        googleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(appleLoginButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
    }
    
    @objc func appleButtonDidTapped() {
        appleTapped?()
    }
    
    @objc func googleButtonDidTapped() {
        googleTapped?()
    }
    
}
