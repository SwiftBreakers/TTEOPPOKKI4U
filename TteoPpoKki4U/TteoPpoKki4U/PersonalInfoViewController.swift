//
//  PersonalInfoViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/29/24.
//

import UIKit
import SnapKit
import PhotosUI
import Firebase
import ProgressHUD
import Kingfisher

class PersonalInfoViewController: UIViewController, PHPickerViewControllerDelegate {
    
    var profileImageView: UIImageView!
    var userNameTextField: CustomTextField!
    var saveButton: UIButton!
    
    var profileImage: UIImage?
    var gotProfileImage: String?
    var profileName: String?
    
    let userManager = UserManager()
    
    
    var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.backward.2")
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.addTarget(nil, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupProfileImageView()
        setupUserNameTextField()
        setupBackButton()
        setupSaveButton()
        getImage()
        navigationController?.isNavigationBarHidden = true
    }
    
    func getImage() {
        profileImageView.kf.setImage(with: URL(string: gotProfileImage!))
    }
    
    
    func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-340)
            make.height.width.equalTo(24)
        }
    }
    
    func setupProfileImageView() {
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .lightGray
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeProfileImage)))
        
        view.addSubview(profileImageView)
        
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.width.height.equalTo(100)
        }
    }
    
    func setupUserNameTextField() {
        userNameTextField = CustomTextField(placeholder: "변경할 닉네임을 입력해주세요.",target: self, action: #selector(doneButtonTapped))
        userNameTextField.borderStyle = .roundedRect
        
        view.addSubview(userNameTextField)
        
        userNameTextField.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
    }
    
    func setupSaveButton() {
        saveButton = UIButton(type: .system)
        saveButton.setImage(UIImage(named: "checkBox"), for: .normal)
        saveButton.tintColor = ThemeColor.mainGreen
        saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
        
        view.addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            //  make.leading.equalTo(backButton.snp.trailing).offset(274)
            make.trailing.equalToSuperview().offset(-30)
            make.width.height.equalTo(24)
            
        }
    }
    
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        
    }
    
    @objc func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
    @objc func changeProfileImage() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let result = results.first else { return }
        
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                guard let self = self else { return }
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.profileImage = image
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }
    
    @objc func saveChanges() {
        ProgressHUD.animate()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var selectedImage = profileImage
        var userName = userNameTextField.text
        
        if userName == "" {
            userName = profileName
        }
        
        if selectedImage == nil {
            KingfisherManager.shared.retrieveImage(with: URL(string: gotProfileImage!)!) { [weak self] result in
                switch result {
                case .success(let image):
                    selectedImage = image.image
                case .failure(let error):
                    self?.showMessage(title: "에러 발생", message: "\(error)가 발생했습니다")
                }
            }
        }
        
        userManager.updateProfile(uid: uid, nickName: userName!, profile: selectedImage!) { [weak self] result in
            switch result {
            case .success(()):
                ProgressHUD.dismiss()
                self?.showMessage(title: "수정 완료", message: "프로필 정보가 수정 되었습니다.") {
                    self?.navigationController?.popViewController(animated: true)
                }
            case .failure(let error) :
                ProgressHUD.dismiss()
                self?.showMessage(title: "에러 발생", message: "\(error.localizedDescription)가 발생했습니다.")
            }
        }
    }
}
