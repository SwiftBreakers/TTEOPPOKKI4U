//
//  ChatViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SnapKit

class ChatViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }()

    private let messageTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter message"
        return textField
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        return button
    }()

    var messages = [Message]()
    var chatRoomId: String!
    var currentUser: UserModel!

    let messageManager = MessageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchMessages()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(messageTextField)
        view.addSubview(sendButton)

        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(messageTextField.snp.top).offset(-8)
        }

        messageTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(44)
        }

        sendButton.snp.makeConstraints { make in
            make.leading.equalTo(messageTextField.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalTo(messageTextField)
            make.width.equalTo(60)
        }

        sendButton.addTarget(self, action: #selector(sendMessageTapped), for: .touchUpInside)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func fetchMessages() {
        guard let chatRoomId = chatRoomId else {
            print("chatRoomId is nil")
            return
        }

        messageManager.listenForMessages(chatRoomId: chatRoomId) { [weak self] messages in
            self?.messages = messages
            self?.tableView.reloadData()
        }
    }

    @objc private func sendMessageTapped() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        guard let userId = Auth.auth().currentUser?.uid else { return }

        messageManager.sendMessage(chatRoomId: chatRoomId, text: text, senderId: userId, senderName: currentUser.nickName) { [weak self] error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                return
            }
            self?.messageTextField.text = nil
        }
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
}
