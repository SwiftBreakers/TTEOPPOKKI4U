//
//  WriteViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/3/24.
//

import UIKit
import SnapKit
import PhotosUI

class WriteViewController: UIViewController {
    
    let starStackView = UIStackView()
    var starButtons: [UIButton] = []
    var selectedRating = 0
    
    let titleTextField = UITextField()
    let contentTextView = UITextView()
    let addImageButton = UIButton()
    let cancelButton = UIButton()
    let submitButton = UIButton()
    
    var selectedImages: [UIImage] = []
    let imageScrollView = UIScrollView()
    let imageStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
//        // Navigation Bar 설정
//        self.title = "후기 작성하기"
//        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        self.navigationItem.backBarButtonItem = backButton
        
        // 별점 라벨
        let starLabel = UILabel()
        starLabel.text = "별점 리뷰 작성"
        starLabel.font = UIFont.boldSystemFont(ofSize: 22)
        view.addSubview(starLabel)
        starLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.centerX.equalToSuperview()
        }
        
        // 별점 버튼들 설정
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 10
        view.addSubview(starStackView)
        starStackView.snp.makeConstraints { make in
            make.top.equalTo(starLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(110)
            make.right.equalToSuperview().offset(-110)
        }
        
        for i in 1...5 {
            let button = UIButton()
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.setImage(UIImage(systemName: "star.fill"), for: .selected)
            button.tintColor = .orange
            button.tag = i
            button.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            starStackView.addArrangedSubview(button)
            starButtons.append(button)
        }
        
        // 제목 텍스트 필드 설정
        titleTextField.placeholder = "제목"
        titleTextField.borderStyle = .roundedRect
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(starStackView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        // 내용 텍스트 뷰 설정
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 5
        contentTextView.font = UIFont.systemFont(ofSize: 17)
        contentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(150)
        }
        
        // 이미지 추가 버튼
        addImageButton.setImage(UIImage(systemName: "camera"), for: .normal)
        addImageButton.backgroundColor = .systemGray5
                addImageButton.layer.cornerRadius = 5
                addImageButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
                view.addSubview(addImageButton)
                addImageButton.snp.makeConstraints { make in
                    make.top.equalTo(contentTextView.snp.bottom).offset(20)
                    make.left.equalToSuperview().offset(20)
                    make.width.height.equalTo(60)
                }
        // MARK: - 여기 스크롤 되는지 모르겠음....
        // 이미지 스크롤뷰 설정
                imageScrollView.showsHorizontalScrollIndicator = false
                view.addSubview(imageScrollView)
                imageScrollView.snp.makeConstraints { make in
                    make.top.equalTo(addImageButton.snp.bottom).offset(40)
                    make.left.equalToSuperview().offset(20)
                    make.right.equalToSuperview().offset(-20)
                    make.height.equalTo(90)
                }
        
        // 이미지 스택뷰 설정
                imageStackView.axis = .horizontal
                imageStackView.spacing = 10
                imageScrollView.addSubview(imageStackView)
                imageStackView.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.left.equalToSuperview().offset(20)
                    make.right.equalToSuperview().offset(-20)
                }
       
        
        // 취소 버튼 설정
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = .systemGray
        cancelButton.layer.cornerRadius = 5
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        // 등록 버튼 설정
        submitButton.setTitle("리뷰 등록", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .orange
        submitButton.layer.cornerRadius = 5
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.equalTo(cancelButton.snp.trailing).offset(16)
            make.height.equalTo(50)
        }
    }
    
    @objc func starButtonTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        for (index, button) in starButtons.enumerated() {
            button.isSelected = index < selectedRating
        }
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func submitButtonTapped() {
        // 등록 버튼 클릭 시 처리 로직 구현
        let title = titleTextField.text ?? ""
        let content = contentTextView.text ?? ""
        print("저장된 제목: \(title)")
        print("저장된 내용: \(content)")
        print("선택된 별점: \(selectedRating)")
        print("선택된 이미지 수: \(selectedImages.count)")
        
        // 데이터 저장 로직 추가 필요
    }
    //5개 이미지만 선택 가능!
    @objc func addImageButtonTapped() {
           var configuration = PHPickerConfiguration()
           configuration.filter = .images
           configuration.selectionLimit = 5
           
           let picker = PHPickerViewController(configuration: configuration)
           picker.delegate = self
           present(picker, animated: true, completion: nil)
       }
    
    
}

extension WriteViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true, completion: nil)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                        guard let self = self else { return }
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                if self.selectedImages.count > 4 {
                                    let alert = UIAlertController(title: "업로드 갯수 제한", message: "이미지 업로드는 5개로 제한됩니다.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                                    self.present(alert, animated: true)
                                } else {
                                    self.selectedImages.append(image)
                                    self.addImageToStackView(image: image)
//                                    let imageView = UIImageView(image: image)
//                                    imageView.contentMode = .scaleAspectFill
//                                    imageView.clipsToBounds = true
//                                    self.imageStackView.addArrangedSubview(imageView)
//                                    imageView.snp.makeConstraints { make in
//                                        make.width.height.equalTo(90)
//                                        imageView.layer.cornerRadius = 10
//                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
    func addImageToStackView(image: UIImage) {
           let containerView = UIView()
           containerView.snp.makeConstraints { make in
               make.width.height.equalTo(90)
           }
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
           
           let imageView = UIImageView(image: image)
           imageView.contentMode = .scaleAspectFill
           imageView.clipsToBounds = true
           containerView.addSubview(imageView)
           imageView.snp.makeConstraints { make in
               make.edges.equalToSuperview()
           }
           
           let removeButton = UIButton(type: .custom)
           removeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
           removeButton.tintColor = .systemGray6
           removeButton.addTarget(self, action: #selector(removeImageButtonTapped(_:)), for: .touchUpInside)
           containerView.addSubview(removeButton)
           removeButton.snp.makeConstraints { make in
               make.top.right.equalToSuperview().inset(5)
               make.width.height.equalTo(20)
           }
           
           imageStackView.addArrangedSubview(containerView)
       }
       
       @objc func removeImageButtonTapped(_ sender: UIButton) {
           
           guard let containerView = sender.superview else { return }
           
           if let index = imageStackView.arrangedSubviews.firstIndex(of: containerView) {
               selectedImages.remove(at: index)
              // print(selectedImages.count)
           }
        
           containerView.removeFromSuperview()
           }
}
