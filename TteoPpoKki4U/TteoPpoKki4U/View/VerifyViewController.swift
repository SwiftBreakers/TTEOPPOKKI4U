//
//  VerifyViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/28.
//

import UIKit
import SnapKit

class VerifyViewController: UIViewController {
    var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "서비스 이용약관에 동의해주세요."
        label.textAlignment = .left
        label.font = ThemeFont.fontBold(size: 40)
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "동네 오픈톡 커뮤니티를 이용해 떡볶이 탐험단을 꾸려보세요!"
        label.textAlignment = .left
        label.font = ThemeFont.fontMedium(size: 20)
        return label
    }()
    
    var serviceVerifyLabel: UILabel = {
        let label = UILabel()
        label.text = "서비스 필수 항목 모두 동의"
        label.font = ThemeFont.fontMedium(size: 20)
        return label
    }()
    
    var privacyVerifyLabel: UILabel = {
        let label = UILabel()
        label.text = "개인정보 수집 및 이용동의"
        label.font = ThemeFont.fontMedium(size: 20)
        return label
    }()
    var communityVerifyLabel: UILabel = {
        let label = UILabel()
        label.text = "커뮤니티 이용동의"
        label.font = ThemeFont.fontMedium(size: 20)
        return label
    }()
    
    lazy var verifyButton: UIButton = createCheckBoxButton()
    var isOn = false
    lazy var movePrivacyButton: UIButton = moveToPrivacyButton()
    lazy var moveCommunityButton: UIButton = moveToPrivacyButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstraints()
    }
    private func createCheckBoxButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.addTarget(self, action: #selector(checkBoxButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .black
        return button
    }
    private func moveToPrivacyButton() -> UIButton {
        let button = UIButton()
        button.setTitle("보기", for: .normal)
        button.addTarget(self, action: #selector(moveToPrivacyButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .black
        return button
    }
    private func moveToCommunityButton() -> UIButton {
        let button = UIButton()
        button.setTitle("보기", for: .normal)
        button.addTarget(self, action: #selector(moveToCommunityButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .black
        return button
    }
    @objc private func moveToPrivacyButtonTapped(_ sender: UIButton) {
        
    }
    @objc private func moveToCommunityButtonTapped(_ sender: UIButton) {
        
    }

    @objc private func checkBoxButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        switch sender {
        case verifyButton:
            isOn.toggle()
        default:
            break
        }
    }
    
    private func setConstraints() {
    
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(verifyButton)
        view.addSubview(serviceVerifyLabel)
        view.addSubview(privacyVerifyLabel)
        view.addSubview(communityVerifyLabel)
        view.addSubview(moveToPrivacyButton())
        view.addSubview(moveToCommunityButton())
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        verifyButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(20)
        }
        serviceVerifyLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(verifyButton)
            make.leading.equalTo(verifyButton.snp.trailing).offset(10)
        }
        privacyVerifyLabel.snp.makeConstraints { make in
            make.top.equalTo(serviceVerifyLabel.snp.bottom).offset(10)
            make.leadingMargin.equalTo(serviceVerifyLabel)
        }
        communityVerifyLabel.snp.makeConstraints { make in
            make.top.equalTo(privacyVerifyLabel.snp.bottom).offset(10)
            make.leadingMargin.equalTo(privacyVerifyLabel)
        }
        movePrivacyButton.snp.makeConstraints { make in
            make.topMargin.equalTo(privacyVerifyLabel)
            make.trailing.equalToSuperview().offset(-10)
        }
        moveCommunityButton.snp.makeConstraints { make in
            make.topMargin.equalTo(communityVerifyLabel)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
}
