//
//  SettingViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/9/24.
//

import UIKit
import SnapKit
import FirebaseAuth

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View 설정
        view.backgroundColor = .white
        title = "Settings"
        
        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        
        // SnapKit을 사용하여 테이블 뷰 레이아웃 설정
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let deleteUserLabel = UILabel()
        deleteUserLabel.text = "회원탈퇴"
        deleteUserLabel.font = UIFont(name: "ThemeFont.fontMedium", size: 18)
        deleteUserLabel.textColor = .systemRed
        deleteUserLabel.textAlignment = .center
        
        cell.contentView.addSubview(deleteUserLabel)
        
        deleteUserLabel.snp.makeConstraints { make in
            make.center.equalTo(cell.contentView)
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
        default: return
        }
    }
    
    // 회원탈퇴 버튼 액션
 func deleteUser() {
        let alert = UIAlertController(title: "회원탈퇴", message: "정말로 회원탈퇴 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in
            //firebase 회원탈퇴
            let user = Auth.auth().currentUser
            
            user?.delete { error in
                if let error = error {
                    print("\(error.localizedDescription)")
                } else {
                    print("회원탈퇴 처리")
                    
                    let scene = UIApplication.shared.connectedScenes.first
                    if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                        sd.switchToGreetingViewController()
                    }
                }
            }
            }))
            present(alert, animated: true, completion: nil)
        }
                                      }
