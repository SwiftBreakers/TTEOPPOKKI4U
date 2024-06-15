//
//  CommunityViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import SnapKit




final class CommunityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        tableView.register(CommunityLocalTableViewCell.self, forCellReuseIdentifier: "CommunityLocalTableViewCell" )
        
        //셀을 오래 누르면 반응하는 기능
        
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        return tableView
    }()
    
    
    
    
    private var data: [ChatData] = [ChatData(name: "qkqk", text: "1213"),
                                    ChatData(name: "dftggg", text: "가나다라"),
                                    ChatData(name: "qkqk", text: "12다13")]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(inputContainerView)
        view.addSubview(tableView)
        tableView.backgroundColor = .black
        tableView.snp.makeConstraints{ $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        setupNavigationBar()
        setupLayout()
        
        setupConstraints()
        styleViews()
        
        
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //셀 누를때 메서드 호출(메뉴알러트)
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .began {
            return
        }
        
        let point = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            let cell = tableView.cellForRow(at: indexPath)
            
        }
    }
    
    
    
    //여기서부터 상단 바
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        let navigationItem = UINavigationItem(title: "커뮤니티")
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
    
    
    
    
    @objc func addButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
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
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
        //        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = CommunityTableViewCell()
        //        cell.titleLabel.text = "안녕하세요 이것저것 다 좋아하지만 떡볶이마을을 가장 추천해요."
        //        cell.titleLabel2.text = "IOS 김건응"
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityLocalTableViewCell", for: indexPath) as! CommunityLocalTableViewCell
        
        cell.titleLabel.text = data[indexPath.row].text
        cell.titleLabel2.text = data[indexPath.row].name// 데이터 소스 배열의 텍스트 설정
        
        return cell
        
    }
    
    
}

extension CommunityViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = CommunityChattingViewController()
        //
        detailVC.hidesBottomBarWhenPushed = true
        //위의 detailVC.hide~ = 탭바 숨겼다 다시 꺼내기
        navigationController?.pushViewController(detailVC, animated: true)
        
        //탭바를 숨겼다 다시 꺼내기
        //        tabBarController?.tabBar.isHidden = true
        
    }
}







