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
        button.cornerRadius = 10
        button.addTarget(self, action: #selector(appleButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
//    private lazy var googleLoginButton: GIDSignInButton = {
//        let button = GIDSignInButton()
//        button.style = .wide
//        button.colorScheme = .light
//        button.layer.cornerRadius = 10
//        button.addTarget(self, action: #selector(googleButtonDidTapped), for: .touchUpInside)
//        return button
//    }()
    
    private lazy var googleLoginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hexString: "F2F2F2")
        button.setImage(UIImage(named: "ios_neutral_sq_SI"), for: .normal)
        button.setImage(UIImage(named: "ios_neutral_sq_SI"), for: .highlighted)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(googleButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var seperateLabel: UILabel = {
        let label = UILabel()
        label.text = "or continue with"
        label.textColor = .gray
        label.font = ThemeFont.fontRegular(size: 12)
        return label
    }()
    
    private lazy var guestLoginButton: UIButton = {
        let button = UIButton(type: .system)
        // 버튼 텍스트 설정
           button.setTitle("게스트로 로그인", for: .normal)
           button.setTitleColor(.gray, for: .normal)
           
           // 버튼 이미지 설정
           let image = UIImage(systemName: "person.crop.circle")?.withRenderingMode(.alwaysTemplate)
           button.setImage(image, for: .normal)
           button.tintColor = .gray // 이미지 색상 설정
           
           // 이미지와 텍스트 사이 간격 설정
           button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
           button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
           
           // 버튼 배경 색상 설정
           button.backgroundColor = .white
           
           // 버튼 테두리 설정
           button.layer.borderWidth = 1
           button.layer.borderColor = UIColor.lightGray.cgColor
           button.layer.cornerRadius = 8 // 원하는 코너 스타일 설정
           
           // 텍스트 폰트 설정
           button.titleLabel?.font = ThemeFont.fontBold()
        
//        var configuration = UIButton.Configuration.plain()
//
//        configuration.image = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(.gray)
//        configuration.imagePadding = 8
//        configuration.imagePlacement = .leading
//        
//        configuration.baseForegroundColor = .gray
//        configuration.cornerStyle = .medium
//        configuration.background.strokeWidth = 1
//        configuration.background.strokeColor = .lightGray
        
//        var container = AttributeContainer()
//        container.font = ThemeFont.fontBold()
//        configuration.attributedTitle = AttributedString("게스트로 로그인", attributes: container)
        
//        button.configuration = configuration
        
        // 상태 업데이트 핸들러를 사용하여 클릭 시 tintColor를 유지
//        button.configurationUpdateHandler = { button in
//            var updatedConfiguration = button.configuration
//            updatedConfiguration?.image = UIImage(systemName: "person.crop.circle")?.withRenderingMode(.alwaysTemplate)
//            updatedConfiguration?.baseForegroundColor = .white
//            button.configuration = updatedConfiguration
//        }
        
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
        [appleLoginButton, googleLoginButton, seperateLabel, guestLoginButton].forEach { button in
            self.addSubview(button)
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
            
        googleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(appleLoginButton.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        
        seperateLabel.snp.makeConstraints { make in
            make.top.equalTo(googleLoginButton.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        guestLoginButton.snp.makeConstraints { make in
            make.top.equalTo(seperateLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
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
