//
//  ChatVC.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Photos
import FirebaseFirestore
import FirebaseAuth

class ChatVC: MessagesViewController {
    
    lazy var cameraBarButtonItem: InputBarButtonItem = {
        let button = InputBarButtonItem(type: .system)
        button.tintColor = ThemeColor.mainOrange
        button.image = UIImage(systemName: "camera")
        button.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        return button
    }()
    
    private let user: User?
    private let customUser: CustomUser?
    let chatFirestoreStream = ChatFirestoreStream()
    let channel: Channel
    var messages = [Message]()
    private var currentDisplayName: String = "Unknown"
    private var isSendingPhoto = false {
        didSet {
            messageInputBar.leftStackViewItems.forEach { item in
                guard let item = item as? InputBarButtonItem else {
                    return
                }
                item.isEnabled = !self.isSendingPhoto
            }
        }
    }
    
    init(user: User, channel: Channel) {
        self.user = user
        self.customUser = nil
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
        
        title = channel.name
    }
    
    init(customUser: CustomUser, channel: Channel) {
        self.user = nil
        self.customUser = customUser
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
        
        title = channel.name
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        chatFirestoreStream.removeListener()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDisplayName { [weak self] displayName in
            self?.currentDisplayName = displayName ?? "Unknown"
            self?.messagesCollectionView.reloadData()
            DispatchQueue.main.async {
                self?.messagesCollectionView.scrollToLastItem()
            }
        }
        
        confirmDelegates()
        configure()
        removeOutgoingMessageAvatars()
        addCameraBarButtonToMessageInputBar()
        listenToMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMessageInputBar()
    }
    
    private func fetchDisplayName(completion: @escaping (String?) -> Void) {
        let userManager = UserManager()
        if let user = user {
            userManager.fetchUserData(uid: user.uid) { error, snapshot in
                if let error = error {
                    print(error)
                    completion(nil)
                    return
                }
                guard let dictionary = snapshot?.value as? [String: Any] else {
                    completion(nil)
                    return
                }
                let currentName = (dictionary[db_nickName] as? String) ?? "Unknown"
                completion(currentName)
            }
        } else if let customUser = customUser {
            completion(customUser.isGuest ? "Guest" : "Unknown")
        } else {
            completion(nil)
        }
    }
    
    private func confirmDelegates() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
    }
    
    private func configure() {
        title = channel.name
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupMessageInputBar() {
        if let user = user {
            messageInputBar.inputTextView.tintColor = ThemeColor.mainOrange
            messageInputBar.sendButton.setTitleColor(ThemeColor.mainOrange, for: .normal)
            messageInputBar.inputTextView.placeholder = "채팅을 입력해주세요!"
        } else if customUser != nil {
            messageInputBar.inputTextView.tintColor = .systemGray
            messageInputBar.sendButton.setTitleColor(.systemGray, for: .normal)
            messageInputBar.inputTextView.placeholder = "채팅 입력을 위해 로그인해주세요!"
        }
    }
    
    private func removeOutgoingMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.setMessageOutgoingAvatarSize(.zero)
        let outgoingLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }
    
    private func addCameraBarButtonToMessageInputBar() {
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraBarButtonItem], forStack: .left, animated: false)
    }
    
    private func insertNewMessage(_ message: Message) {
        messages.append(message)
        messages.sort()
        
        messagesCollectionView.reloadData()
    }
    
    private func listenToMessages() {
        guard let id = channel.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        chatFirestoreStream.subscribe(id: id) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.loadImageAndUpdateCells(messages)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadImageAndUpdateCells(_ messages: [Message]) {
        let dispatchGroup = DispatchGroup()
        
        messages.forEach { message in
            var message = message
            if let url = message.downloadURL {
                dispatchGroup.enter()
                FirebaseStorageManager.downloadImage(url: url) { [weak self] result in
                    defer { dispatchGroup.leave() }
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let image):
                        message.image = image
                        self.insertNewMessage(message)
                    case .failure(let error):
                        print("Failed to download image: \(error)")
                        self.insertNewMessage(message)
                    }
                }
            } else {
                insertNewMessage(message)
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    @objc private func didTapCameraButton() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true)
    }
}

extension ChatVC: MessagesDataSource {
    var currentSender: SenderType {
        if let user = user {
            return Sender(senderId: user.uid, displayName: currentDisplayName)
        } else if let customUser = customUser {
            return Sender(senderId: customUser.uid, displayName: currentDisplayName)
        } else {
            fatalError("No valid user found.")
        }
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                                                             .foregroundColor: UIColor(white: 0.3, alpha: 1)])
    }
}

extension ChatVC: MessagesLayoutDelegate {
    // 아래 여백
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    // 말풍선 위 이름 나오는 곳의 height
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}

// 상대방이 보낸 메시지, 내가 보낸 메시지를 구분하여 색상과 모양 지정
extension ChatVC: MessagesDisplayDelegate {
    // 말풍선의 배경 색상
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? ThemeColor.mainOrange : .incomingMessageBackground
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .white
    }
    
    // 말풍선의 꼬리 모양 방향
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let cornerDirection: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(cornerDirection, .curved)
    }
}

extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        Message.fetchDisplayName(userManager: UserManager()) { [weak self] displayName in
            guard let displayName = displayName, let self = self else {
                self?.showMessage(title: "로그인이 필요한 기능입니다.", message: "게스트는 메세지를 보낼 수 없습니다.")
                return
            }
            
            var message: Message
            if let user = self.user {
                message = Message(user: user, content: text, displayName: displayName)
            } else if let customUser = self.customUser {
                message = Message(customUser: customUser, content: text, displayName: displayName)
            } else {
                print("No valid user found")
                return
            }
            
            self.chatFirestoreStream.save(message) { error in
                if let error = error {
                    print(error)
                    return
                }
                self.messagesCollectionView.scrollToLastItem()
            }
            inputBar.inputTextView.text.removeAll()
        }
    }
}

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let asset = info[.phAsset] as? PHAsset {
            let imageSize = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: imageSize,
                                                  contentMode: .aspectFit,
                                                  options: nil) { image, _ in
                guard let image = image else { return }
                self.sendPhoto(image)
            }
        } else if let image = info[.originalImage] as? UIImage {
            sendPhoto(image)
        }
    }
    
    private func sendPhoto(_ image: UIImage) {
        guard !isSendingPhoto else { return }
        isSendingPhoto = true
        
        _ = FirebaseStorageManager.uploadImage(image: image, channel: channel, progress: { progress in
            // 업로드 진행 상황을 처리할 수 있습니다. 예: progress bar 업데이트
            print("Upload progress: \(progress * 100)%")
        }, completion: { [weak self] result in
            self?.isSendingPhoto = false
            guard let self = self else { return }
            
            switch result {
            case .success(let url):
                Message.fetchDisplayName(userManager: UserManager()) { displayName in
                    guard let displayName = displayName else {
                        print("Failed to fetch display name")
                        return
                    }
                    
                    var message: Message
                    if let user = self.user {
                        message = Message(user: user, image: image, displayName: displayName)
                    } else if let customUser = self.customUser {
                        message = Message(customUser: customUser, image: image, displayName: displayName)
                    } else {
                        print("No valid user found")
                        return
                    }
                    
                    message.downloadURL = url
                    self.chatFirestoreStream.save(message) { error in
                        if let error = error {
                            print(error)
                            return
                        }
                        self.messagesCollectionView.scrollToLastItem(animated: true)
                    }
                }
            case .failure(let error):
                print("Failed to upload image: \(error)")
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
