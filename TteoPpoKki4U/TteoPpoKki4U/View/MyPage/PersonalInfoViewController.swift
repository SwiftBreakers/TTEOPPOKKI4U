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
import Combine

class PersonalInfoViewController: UIViewController, PHPickerViewControllerDelegate {
    
    var profileImageView: UIImageView!
    var userNameTextField: CustomTextField!
    var saveButton: UIButton!
    var validateButton: UIButton = {
        let button = UIButton()
        button.setTitle("중복확인", for: .normal)
        button.addTarget(self, action: #selector(validateName), for: .touchUpInside)
        button.titleLabel?.font = ThemeFont.fontBold(size: 14)
        button.titleLabel?.textColor = .white
        button.backgroundColor = ThemeColor.mainOrange
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var validateLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontBold(size: 18)
        label.textColor = ThemeColor.mainBlack
        label.text = "닉네임 변경 전 중복확인 검사를 해주세요."
        return label
    }()
    
    var isValidate = false
    var profileImage: UIImage?
    var gotProfileImage: String?
    var profileName: String?
    
    let userManager = UserManager()
    var viewModel: ManageViewModel!
    private var cancellables = Set<AnyCancellable>()
    
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
        //setupBackButton()
        setupSaveButton()
        getImage()
        userNameTextField.text = profileName
    }
    
    deinit {
        profileImage = nil
        gotProfileImage = nil
        profileName = nil
        
        profileImageView.kf.cancelDownloadTask()
        profileImageView.image = nil
        
        userNameTextField.text = nil
        saveButton = nil
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
        view.addSubview(validateButton)
        view.addSubview(validateLabel)
        
        userNameTextField.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(40)
        }
        
        validateButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.leading.equalTo(userNameTextField.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        validateLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
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
    
    
    @objc func validateName() {
        let manageManager = ManageManager()
        viewModel = ManageViewModel(manageManager: manageManager)
        
        viewModel.getUsers()
        
        guard let nickName = userNameTextField.text else { return }
        
        viewModel.$userArray.sink { [weak self] modelArray in
                if modelArray.contains(where: { $0.nickName == nickName }) {
                    self?.isValidate = false
                    self?.validateLabel.textColor = .red
                    self?.validateLabel.text = "이미 닉네임이 존재합니다."
                } else {
                    self?.isValidate = true
                    self?.validateLabel.textColor = .blue
                    self?.validateLabel.text = "입력하신 닉네임은 사용 가능합니다."
                }
                
            }.store(in: &cancellables)
    }
    
    
    @objc func saveChanges() {
        
        if isValidate {
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
        } else {
            showMessage(title: "중복확인을 해주세요", message: "닉네임 중복확인을 먼저 해주세요.")
        }
        
    }
}
