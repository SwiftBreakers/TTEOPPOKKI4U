//
//  CommunityChattingViewController.swift
//  TteoPpoKki4U
//
//  Created by 김건응 on 6/13/24.
//

import UIKit
import SnapKit


   

    final class CommunityChattingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        //바닥 제약 조정
        var tableViewBottomConstraint: NSLayoutConstraint?
        var inputContainerViewBottomConstraint: NSLayoutConstraint?
        
        //상단 바
        private let navigationBar = UINavigationBar()
        
        //하단 바
        private let inputContainerView = UIView()
        private let inputTextField = UITextField()
        private let sendButton = UIButton(type: .system)
        //사진선택버튼
        private let PictureAddButton = UIButton()
        
        
        
        //테이블뷰
        private lazy var tableView: UITableView = {
            let tableView = UITableView()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
            tableView.backgroundColor = UIColor.black
            //테이블뷰 셀 줄 없애기
            
            tableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "cell" )
            
            //셀을 오래 누르면 반응하는 기능
            tableView.register(CommunityTableViewCellSelf.self, forCellReuseIdentifier: "cellSelf" )
            tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
            return tableView
        }()
        
        
        
        
        private var data: [ChatData] = [ChatData(name: "qkqk", text: "1213"),
                                        ChatData(name: "dftggg", text: "가나다라"),
                                        ChatData(name: "qkqk", text: "12다13")]
        
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.addSubview(tableView)
            tableView.backgroundColor = .black
            tableView.snp.makeConstraints{ $0.edges.equalTo(view.safeAreaLayoutGuide)
            }
            setupNavigationBar()
            setupLayout()
            setupViews()
            setupConstraints()
            styleViews()
            setupPictureAddButton()
            
            
            sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
            
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            inputTextField.becomeFirstResponder()
        }
        
        //셀 누를때 메서드 호출(메뉴알러트)
        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state != .began {
                return
            }

            let point = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                let cell = tableView.cellForRow(at: indexPath)
                showActionSheet(for: cell, at: indexPath)
            }
        }

        func showActionSheet(for cell: UITableViewCell?, at indexPath: IndexPath) {
            let actionSheet = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)

            let deleteAction = UIAlertAction(title: "신고하기", style: .destructive) { action in
                // 삭제 관련 로직 처리
                print("Reporting chat at \(indexPath.row)")
            }
            
            let shareAction = UIAlertAction(title: "공유하기", style: .default) { action in
                // 공유 관련 로직 처리
                print("Sharing chat at \(indexPath.row)")
            }
            
            let editAction = UIAlertAction(title: "차단하기", style: .default) { action in
                // 편집 관련 로직 처리
                print("blocking chat at \(indexPath.row)")
            }

            let cancelAction = UIAlertAction(title: "취소", style: .cancel)

            actionSheet.addAction(deleteAction)
            actionSheet.addAction(shareAction)
            actionSheet.addAction(editAction)
            actionSheet.addAction(cancelAction)

            if let popoverController = actionSheet.popoverPresentationController, let cell = cell {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }

            present(actionSheet, animated: true)
        }
        
        //여기서부터 상단 바
        
        private func setupNavigationBar() {
            navigationBar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(navigationBar)
            
            let navigationItem = UINavigationItem(title: "채팅")
            navigationBar.setItems([navigationItem], animated: false)
        }
        
        private func setupLayout() {
            NSLayoutConstraint.activate([
                navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigationBar.heightAnchor.constraint(equalToConstant: 44) // 44픽셀은 일반적인 네비게이션 바 높이
            ])
        }
        //상단바 끝
        
        //컨트롤러가 해제될 때 노티피케이션 관찰자를 제거하는 부분(키보드 높이만큼 올라고 내리는)
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        //하단 바 시작
        
        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                UIView.animate(withDuration: 0.3) {
                            self.tableViewBottomConstraint?.constant = -keyboardSize.height
                            self.inputContainerViewBottomConstraint?.constant = -keyboardSize.height
                            self.view.layoutIfNeeded()
                        }
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            UIView.animate(withDuration: 0.3) {
                    self.tableViewBottomConstraint?.constant = 0
                    self.inputContainerViewBottomConstraint?.constant = 0
                    self.view.layoutIfNeeded()
                }
        }
        
        
        //text바 시작
        private func setupViews() {
            view.addSubview(inputContainerView)
            
            inputContainerView.addSubview(inputTextField)
            inputTextField.placeholder = "채팅을 입력하세요"
            
            inputContainerView.addSubview(sendButton)
            sendButton.setTitle("전송", for: .normal)
            
            inputContainerView.addSubview(PictureAddButton)
            PictureAddButton.setTitle("추가", for: .normal)
        }
        
        //사진추가 버튼
        private func setupPictureAddButton() {
            PictureAddButton.translatesAutoresizingMaskIntoConstraints = false
    //        PictureAddButton.setTitle("추가", for: .normal)
            PictureAddButton.setTitleColor(.blue, for: .normal)
            PictureAddButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
            view.addSubview(PictureAddButton)
            
            PictureAddButton.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(10)
                make.bottom.equalToSuperview().inset(30)
                make.width.height.equalTo(50)
            }
        }
        @objc func addButtonTapped() {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                present(imagePickerController, animated: true, completion: nil)
            }
        
        // UIImagePickerControllerDelegate 메소드
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    // Handle the selected image
                    print("Image Selected")
                    // You can now do something with the selected image
                }
                picker.dismiss(animated: true, completion: nil)
            }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true, completion: nil)
            }
        
        
        //사진추가버튼 끝
        
        
        private func setupConstraints() {
            
            tableView.snp.makeConstraints { make in
                //바닥 제약을 변수에 저장하고 조정하는
                    tableViewBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint.layoutConstraints.first
                    make.top.left.right.equalTo(view.safeAreaLayoutGuide)
                }
            
            inputContainerView.snp.makeConstraints { make in
                inputContainerViewBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint.layoutConstraints.first
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(80)  // Adjust the height as needed
            }
            
            sendButton.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(20)
                make.centerY.equalToSuperview().offset(-20)
                make.height.equalTo(30)
                make.width.equalTo(60)
            }
            
            inputTextField.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(50)
                make.right.equalTo(sendButton.snp.left).offset(-10)
                make.centerY.equalToSuperview().offset(-20)
                make.height.equalTo(30)
            }
            
            PictureAddButton.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(10)
                make.right.equalTo(inputTextField.snp.left).offset(-4)
                make.centerY.equalToSuperview().offset(-10)
                make.height.equalTo(30)
            }
            
        }
        
        private func styleViews() {
            inputContainerView.backgroundColor = .lightGray  // Customize color as needed
            inputTextField.borderStyle = .roundedRect
            sendButton.backgroundColor = .black  // Customize button color as needed
            sendButton.setTitleColor(.white, for: .normal)
        }
        
        //하단 바 끝
        
        //    func numberOfSections(in tableView: UITableView) -> Int {
        //            return data.count
        //        }
        //
        
        @objc private func sendMessage() {
                if let message = inputTextField.text, !message.isEmpty {
                    data.append(ChatData(name: "김건응", text: message))
    //                let newIndexPath = IndexPath(row: data.count - 1, section: 0)
    //                tableView.insertRows(at: [newIndexPath], with: .automatic)
                    tableView.reloadData()
                    inputTextField.text = "" // 메시지 전송 후 입력 필드 초기화
                }
            }
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return data.count
    //        return messages.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //        let cell = CommunityTableViewCell()
            //        cell.titleLabel.text = "안녕하세요 이것저것 다 좋아하지만 떡볶이마을을 가장 추천해요."
            //        cell.titleLabel2.text = "IOS 김건응"
            
            if data[indexPath.row].name == "김건응" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelf", for: indexPath) as! CommunityTableViewCellSelf
                
                cell.titleLabel2.text = data[indexPath.row].name
                cell.titleLabel.text = data[indexPath.row].text
                // 데이터 소스 배열의 텍스트 설정
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommunityTableViewCell
                
                cell.titleLabel.text = data[indexPath.row].text
                cell.titleLabel2.text = data[indexPath.row].name// 데이터 소스 배열의 텍스트 설정
                
                return cell
                
            }
            
           
        }
        
        
        
        
    }
