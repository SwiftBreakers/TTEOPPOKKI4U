//
//  PersonalInfoViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/29/24.
//

import UIKit
import SnapKit
import PhotosUI

class PersonalInfoViewController: UIViewController, PHPickerViewControllerDelegate {

       var profileImageView: UIImageView!
       var userNameTextField: UITextField!
       var saveButton: UIButton!

       override func viewDidLoad() {
           super.viewDidLoad()
           self.view.backgroundColor = .systemBackground
           
           setupProfileImageView()
           setupUserNameTextField()
           setupSaveButton()
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
          userNameTextField = UITextField()
          userNameTextField.borderStyle = .roundedRect
          userNameTextField.placeholder = "변경할 닉네임을 입력해주세요."
          
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
          saveButton.setTitle("저장", for: .normal)
          saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
          
          view.addSubview(saveButton)
          
          saveButton.snp.makeConstraints { make in
              make.top.equalTo(userNameTextField.snp.bottom).offset(20)
              make.centerX.equalToSuperview()
          }
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
                          self.profileImageView.image = image
                      }
                  }
              }
          }
      }

      @objc func saveChanges() {
          let userName = userNameTextField.text ?? ""
          //사용자 이름 및 프로필 사진을 저장
          print("Profile updated: \(userName)")
      }
}
