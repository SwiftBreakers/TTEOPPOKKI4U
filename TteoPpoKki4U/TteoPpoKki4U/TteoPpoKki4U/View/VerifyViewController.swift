//
//  VerifyViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/28.
//

import UIKit
import SnapKit
import FirebaseAuth

class VerifyViewController: UIViewController {
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "서비스 이용약관에 동의해주세요."
        label.textAlignment = .left
        label.font = ThemeFont.fontBold(size: 25)
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "동네 오픈톡 커뮤니티를 이용해 떡볶이 탐험단을 꾸려보세요!"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = ThemeFont.fontMedium(size: 18)
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    
    lazy var serviceVerifyLabel: UILabel = {
        let label = UILabel()
        label.text = "서비스 필수 항목 모두 동의"
        label.font = ThemeFont.fontMedium(size: 18)
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    
    lazy var privacyVerifyLabel: UILabel = {
        let label = UILabel()
        label.text = "개인정보 처리방침"
        label.font = ThemeFont.fontMedium(size: 16)
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    
    lazy var communityVerifyLabel: UILabel = {
        let label = UILabel()
        label.text = "서비스 이용약관"
        label.font = ThemeFont.fontMedium(size: 16)
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    
    lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.addTarget(self, action: #selector(checkBoxButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .black
        button.titleLabel?.textColor = ThemeColor.mainBlack
        return button
    }()
    
    lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle("보기", for: .normal)
        button.setTitleColor(ThemeColor.mainBlack, for: .normal)
        button.titleLabel?.font = ThemeFont.fontRegular(size: 16)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(moveToPrivacyButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var communityButton: UIButton = {
        let button = UIButton()
        button.setTitle("보기", for: .normal)
        button.setTitleColor(ThemeColor.mainBlack, for: .normal)
        button.titleLabel?.font = ThemeFont.fontRegular(size: 16)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(moveToCommunityButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(ThemeColor.mainBlack, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(closedTapped), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("가입", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = ThemeColor.mainOrange
        button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var hStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [closeButton, submitButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 10
        return view
    }()
    
    var isOn = false
    let userManager = UserManager()
    var signViewModel: SignViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setConstraints()
    }

    
    private func setConstraints() {
    
        [ titleLabel,
            descriptionLabel,
            checkButton,
            serviceVerifyLabel,
            privacyVerifyLabel,
            communityVerifyLabel,
            privacyButton,
            communityButton,
            hStackView
        ].forEach { view.addSubview($0) }
        
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(20)
        }
        serviceVerifyLabel.snp.makeConstraints { make in
            make.topMargin.equalTo(checkButton)
            make.leading.equalTo(checkButton.snp.trailing).offset(10)
        }
        privacyVerifyLabel.snp.makeConstraints { make in
            make.top.equalTo(serviceVerifyLabel.snp.bottom).offset(10)
            make.leading.equalTo(serviceVerifyLabel.snp.leading)
        }
        communityVerifyLabel.snp.makeConstraints { make in
            make.top.equalTo(privacyVerifyLabel.snp.bottom).offset(10)
            make.leading.equalTo(privacyVerifyLabel.snp.leading)
        }
        privacyButton.snp.makeConstraints { make in
            make.centerY.equalTo(privacyVerifyLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        communityButton.snp.makeConstraints { make in
            make.centerY.equalTo(communityVerifyLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        hStackView.snp.makeConstraints { make in
            make.top.equalTo(communityVerifyLabel.snp.bottom).offset(350)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-80)
        }
    }
    @objc private func moveToPrivacyButtonTapped(_ sender: UIButton) {
        let privacyVC = PrivacyPolicyViewController()
        present(privacyVC, animated: true)
    }
    
    @objc private func moveToCommunityButtonTapped(_ sender: UIButton) {
        let communityPrivacyVC = CommunityPolicyViewController()
        present(communityPrivacyVC, animated: true)
    }

    @objc private func checkBoxButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        switch sender {
        case checkButton:
            isOn.toggle()
        default:
            break
        }
    }
    @objc func closedTapped() {
        let signManager = SignManager()
        signViewModel = SignViewModel(signManager: signManager)
        signViewModel?.signOut { [weak self] in
            self?.dismiss(animated: true)
            print("signout")
        }
    }
    
    @objc func submitTapped() {
        if isOn {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let scene = UIApplication.shared.connectedScenes.first
            if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                userManager.setAgreeProfile(uid: uid, isAgree: isOn) { result in
                    switch result {
                    case .success(()):
                        sd.switchToMainTabBarController()
                    case .failure(let error):
                        print(error)
                        return
                    }
                }
            }
        } else {
            showMessage(title: "안내", message: "약관에 동의를 해주세요.")
        }
    }
}
