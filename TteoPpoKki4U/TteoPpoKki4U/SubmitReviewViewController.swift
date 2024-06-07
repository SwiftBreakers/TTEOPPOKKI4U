////
////  SubmitReviewViewController.swift
////  TteoPpoKki4U
////
////  Created by 박미림 on 6/3/24.
////
//
//import UIKit
//import SnapKit
//
//class SubmitReviewViewController: UIViewController {
//
//    // UI 요소들 정의
//    let titleLabel = UILabel()
//    let contentTextView = UITextView()
//    let saveButton = UIButton()
//    var starButtons: [UIButton] = []
//    var selectedRating = 0
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//
//    func setupUI() {
//        view.backgroundColor = .white
//
//        // 제목
//        titleLabel.text = "리뷰 작성"
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
//        view.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
//            make.centerX.equalToSuperview()
//        }
//
//        // 별점 버튼
//        let starStackView = UIStackView()
//        starStackView.axis = .horizontal
//        starStackView.distribution = .fillEqually
//        starStackView.spacing = 10
//        view.addSubview(starStackView)
//        starStackView.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//        }
//
//        for i in 1...5 {
//            let button = UIButton()
//            button.setImage(UIImage(systemName: "star"), for: .normal)
//            button.setImage(UIImage(systemName: "star.fill"), for: .selected)
//            button.tag = i
//            button.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
//            starStackView.addArrangedSubview(button)
//            starButtons.append(button)
//        }
//
//        // 제목 텍스트필드
//        let titleTextField = UITextField()
//        titleTextField.placeholder = "제목"
//        titleTextField.borderStyle = .roundedRect
//        view.addSubview(titleTextField)
//        titleTextField.snp.makeConstraints { make in
//            make.top.equalTo(starStackView.snp.bottom).offset(20)
//            make.left.equalToSuperview().offset(20)
//            make.right.equalToSuperview().offset(-20)
//        }
//
//        // 내용 텍스트뷰
//        contentTextView.layer.borderWidth = 1
//        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
//        contentTextView.layer.cornerRadius = 5
//        view.addSubview(contentTextView)
//        contentTextView.snp.makeConstraints { make in
//            make.top.equalTo(titleTextField.snp.bottom).offset(20)
//            make.left.equalToSuperview().offset(20)
//            make.right.equalToSuperview().offset(-20)
//            make.height.equalTo(200)
//        }
//
//        // 저장 버튼
//        saveButton.setTitle("저장", for: .normal)
//        saveButton.backgroundColor = .systemBlue
//        saveButton.layer.cornerRadius = 5
//        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
//        view.addSubview(saveButton)
//        saveButton.snp.makeConstraints { make in
//            make.top.equalTo(contentTextView.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(100)
//            make.height.equalTo(50)
//        }
//    }
//
//    @objc func starButtonTapped(_ sender: UIButton) {
//        selectedRating = sender.tag
//        for (index, button) in starButtons.enumerated() {
//            button.isSelected = index < selectedRating
//        }
//    }
//
//    @objc func saveButtonTapped() {
//        // 저장 버튼 클릭 시 처리 로직 구현
//      //  let title = titleTextField.text ?? ""
//     //   let content = contentTextView.text ?? ""
//      //  print("저장된 제목: \(title)")
//      //  print("저장된 내용: \(content)")
//       // print("선택된 별점: \(selectedRating)")
//    }
//}
//
