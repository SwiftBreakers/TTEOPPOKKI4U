//
//  SettingViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/9/24.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabaseInternal
import FirebaseDatabase

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    
    var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.backward.2")
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.addTarget(nil, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    let signManager = SignManager()
    lazy var viewModel = SignViewModel(signManager: signManager)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View 설정
        view.backgroundColor = .white
        title = "Settings"
        
        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        
        // SnapKit을 사용하여 테이블 뷰 레이아웃 설정
        
        
        setupBackButton()
        navigationController?.isNavigationBarHidden = true
        tableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-340)
            make.height.equalTo(30)
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        indexPath.row
        if indexPath.row == 0 {
            let deleteUserLabel = UILabel()
            deleteUserLabel.text = "회원탈퇴"
            deleteUserLabel.font = UIFont(name: "ThemeFont.fontMedium", size: 18)
            deleteUserLabel.textColor = .red
            deleteUserLabel.textAlignment = .center
            
            cell.contentView.addSubview(deleteUserLabel)
            cell.backgroundColor = .white
            cell.selectionStyle = .none
            deleteUserLabel.snp.makeConstraints { make in
                make.center.equalTo(cell.contentView)
            }
            
            
            
        } else if indexPath.row == 1 {
            
            let deleteUserLabel = UILabel()
            deleteUserLabel.text = "이용약관"
            deleteUserLabel.font = UIFont(name: "ThemeFont.fontMedium", size: 18)
            deleteUserLabel.textColor = .red
            deleteUserLabel.textAlignment = .center
            
            cell.contentView.addSubview(deleteUserLabel)
            cell.backgroundColor = .white
            cell.selectionStyle = .none
            deleteUserLabel.snp.makeConstraints { make in
                make.center.equalTo(cell.contentView)
            }
            
        }
        
        
        
        // 회원탈퇴 버튼 설정
        //        if indexPath.row == 0 {
        //            let deleteButton = UIButton(type: .system)
        //            deleteButton.setTitle("회원탈퇴", for: .normal)
        //            deleteButton.setTitleColor(.red, for: .normal)
        //            deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        //
        //            cell.contentView.addSubview(deleteButton)
        //
        //            // SnapKit을 사용하여 버튼 레이아웃 설정
        //            deleteButton.snp.makeConstraints { make in
        //                make.center.equalTo(cell.contentView)
        //            }
        //        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: deleteUser()
        case 1: let privacyVC = PrivacyPolicyViewController()  // 개인정보 뷰컨 인스턴스 생성
            navigationController?.pushViewController(privacyVC, animated: true)
        default: return
        }
    }
    
    // 회원탈퇴 버튼 액션
    func deleteUser() {
        let alert = UIAlertController(title: "회원탈퇴", message: "정말로 회원탈퇴 하시겠습니까? 작성 리뷰는 자동으로 삭제되지 않습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in
            //firebase 회원탈퇴
            self.viewModel.deleteUserAccount { result in
                switch result {
                case .success:
                    let scene = UIApplication.shared.connectedScenes.first
                    if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                        sd.switchToGreetingViewController()
                    }
                case .failure(let error):
                    // 오류 처리
                    print("회원 탈퇴 오류: \(error)")
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
   
    
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        
    }
    
}
