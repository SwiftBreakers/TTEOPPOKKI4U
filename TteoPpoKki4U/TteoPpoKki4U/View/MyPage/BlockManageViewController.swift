//
//  BlockMangaeViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/30/24.
//

import UIKit
import FirebaseAuth

class BlockManageViewController: UIViewController {

    private var tableView: UITableView!
    private var blockedUsers: [String] = []
    private let viewModel = ChatReportViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
        fetchBlockedUsers()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BlockedUserCell.self, forCellReuseIdentifier: "BlockedUserCell")
        tableView.backgroundColor = .white
        view.addSubview(tableView)
    }
    
    private func fetchBlockedUsers() {
        viewModel.fetchBlockedUsers { [weak self] result in
            switch result {
            case .success(let users):
                self?.blockedUsers = users
                self?.tableView.reloadData()
            case .failure(let error):
                print("Failed to fetch blocked users: \(error)")
            }
        }
    }
}

extension BlockManageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserCell", for: indexPath) as! BlockedUserCell
        let userId = blockedUsers[indexPath.row]
        cell.configure(with: userId)
        cell.unblockButton.addTarget(self, action: #selector(unblockButtonTapped(_:)), for: .touchUpInside)
        return cell
    }

    @objc private func unblockButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? BlockedUserCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let userIdToUnblock = blockedUsers[indexPath.row]
        
        showMessageWithCancel(title: "차단 해제", message: "정말 이 유저를 차단 해제하시겠습니까?") { [weak self] in
            self?.unblockUser(userId: userIdToUnblock)
            self?.showMessage(title: "안내", message: "선택하신 유저가 차단 해제 되었습니다.")
        }
   
    }
    
    private func unblockUser(userId: String) {
        guard let myUid = Auth.auth().currentUser?.uid else { return }
        
        viewModel.unblockUser(myUid: myUid, senderName: userId) { [weak self] result in
            switch result {
            case .success:
                self?.blockedUsers.removeAll { $0 == userId }
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error unblocking user: \(error)")
            }
        }
    }
}
