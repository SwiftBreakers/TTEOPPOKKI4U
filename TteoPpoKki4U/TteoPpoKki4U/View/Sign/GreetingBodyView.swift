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
        button.style = .wide
        button.colorScheme = .light
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(googleButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var guestLoginButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        
        configuration.image = UIImage(systemName: "person.crop.circle")
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = ThemeColor.mainOrange
        configuration.cornerStyle = .medium
        
        var container = AttributeContainer()
        container.font = ThemeFont.fontBold()
        configuration.attributedTitle = AttributedString("게스트로 로그인", attributes: container)
        
        button.configuration = configuration
        
        // 상태 업데이트 핸들러를 사용하여 클릭 시 tintColor를 유지
        button.configurationUpdateHandler = { button in
            var updatedConfiguration = button.configuration
            updatedConfiguration?.image = UIImage(systemName: "person.crop.circle")?.withRenderingMode(.alwaysTemplate)
            updatedConfiguration?.baseForegroundColor = .white
            button.configuration = updatedConfiguration
        }
        
        button.addTarget(self, action: #selector(guestButtonDidTapped), for: .touchUpInside)
        
        return button
    }()
    
    var appleTapped: (() -> Void)?
    var googleTapped: (() -> Void)?
    var guestTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        [appleLoginButton, googleLoginButton, guestLoginButton].forEach { button in
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
            make.leading.equalToSuperview().offset(17)
            make.trailing.equalToSuperview().offset(-17)
            make.height.equalTo(65)
        }
        
        guestLoginButton.snp.makeConstraints { make in
            make.top.equalTo(googleLoginButton.snp.bottom).offset(20)
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
    
    @objc func guestButtonDidTapped() {
        guestTapped?()
    }
}
