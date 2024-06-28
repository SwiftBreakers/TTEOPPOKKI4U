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
import Kingfisher
import ProgressHUD

class ChatVC: MessagesViewController {
    
    lazy var addBarButtonItem: InputBarButtonItem = {
        let button = InputBarButtonItem(type: .system)
        button.tintColor = ThemeColor.mainOrange
        button.image = UIImage(systemName: "paperclip")
        button.addTarget(self, action: #selector(presentInputActionSheet), for: .touchUpInside)
        return button
    }()
    
    let chatFirestoreStream = ChatFirestoreStream()
    let chatManager = ChatManager()
    private var user: User?
    private var customUser: CustomUser?
    let channel: Channel
    var messages = [Message]()
    var messagesByDate: [Date: [Message]] = [:]
    var sortedDates: [Date] = []
    private var profileImageUrls = [String: String]()
    private var imageCache = [String: UIImage]()
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
    var userData: ReportUserData?
    var isLocation: Bool?
    
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
        user = nil
        customUser = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureColor()
        
        fetchDisplayNameAndProfileImage { [weak self] displayName, imageUrl in
            self?.currentDisplayName = displayName ?? "Unknown"
            if let profileImageUrl = imageUrl, let userId = self?.user?.uid {
                self?.profileImageUrls[userId] = profileImageUrl
            }
            self?.messagesCollectionView.reloadData()
            DispatchQueue.main.async {
                self?.messagesCollectionView.scrollToLastItem()
            }
        }
        
        getSenderImage()
        confirmDelegates()
        removeOutgoingMessageAvatars()
        addCameraBarButtonToMessageInputBar()
        listenToMessages()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        messagesCollectionView.addGestureRecognizer(tapGesture)
        
        // 커스텀 메뉴 항목 추가
        //        let blockMenuItem = UIMenuItem(title: "차단", action: #selector(MessageCollectionViewCell.block(_:)))
        let reportMenuItem = UIMenuItem(title: "신고", action: #selector(MessageCollectionViewCell.report(_:)))
        UIMenuController.shared.menuItems = [/*blockMenuItem, */reportMenuItem]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentUser = Auth.auth().currentUser {
            self.user = currentUser
            self.customUser = nil
        } else {
            self.user = nil
            self.customUser = CustomUser(guestUID: "guest")
        }
        
        setupMessageInputBar()
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setToolbarHidden(true, animated: false)
    }
    func groupMessagesByDate() {
        let calendar = Calendar.current
        messagesByDate = Dictionary(grouping: messages) { message in
            let date = calendar.startOfDay(for: message.sentDate)
            return date
        }
        for (date, msgs) in messagesByDate {
                messagesByDate[date] = msgs.sorted { $0.sentDate < $1.sentDate }
            }
        // 날짜 배열을 정렬된 순서로 유지
        sortedDates = messagesByDate.keys.sorted(by: <)
    }
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(MessageCollectionViewCell.block(_:)) {
            return true
        } else {
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(MessageCollectionViewCell.report(_:)) {
            if let _ = Auth.auth().currentUser?.uid {
                // 1. 선택한 메시지 가져오기
                let selectedMessage = messages[indexPath.section]
                
                // 2. ReportUserData 생성
                let reportData = ReportUserData(title: "제목", // 원하는 신고 제목 설정
                                                uid: self.user?.uid ?? "", // 사용자 ID
                                                senderId: selectedMessage.sender.senderId, // 보낸 사람 ID
                                                content: selectedMessage.content, // 메시지 내용
                                                sentDate: selectedMessage.sentDate, // 메시지 전송 날짜
                                                reportCount: 0, // 초기 신고 수
                                                isActive: true, // 활성 상태
                                                channel: channel.name) // 채널 확인
                
                // 3. ChatReportViewController로 전달
                let reportVC = ChatReportViewController(userData: reportData)
                self.present(reportVC, animated: true)
            } else {
                super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
            }
        }
    }
    
    
    private func configureColor() {
        view.backgroundColor = .white
        messagesCollectionView.backgroundColor = .white
        messageInputBar.backgroundColor = .white
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.textColor = .black
        navigationController?.navigationBar.tintColor = ThemeColor.mainOrange
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: ThemeColor.mainBlack,
            NSAttributedString.Key.font: ThemeFont.fontBold(size: 18)
        ]
        title = channel.name
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func getSenderImage() {
        chatManager.getSenders(channelName: channel.name) {[weak self] senderIds in
            self?.fetchProfileImages(for: senderIds)
        }
    }
    
    private func fetchDisplayNameAndProfileImage(completion: @escaping (String?, String?) -> Void) {
        fetchUserDataAndProfileImage { displayName, profileImageUrl, _ in
            completion(displayName, profileImageUrl)
        }
    }
    
    private func fetchProfileImages(for senderIds: [String]) {
        senderIds.forEach { senderId in
            fetchUserDataAndProfileImage(for: senderId) { [weak self] _, imageUrl, _ in
                if let profileImageUrl = imageUrl {
                    self?.profileImageUrls[senderId] = profileImageUrl
                    self?.messagesCollectionView.reloadData()  // Reload to update avatars
                }
            }
        }
    }
    
    
    private func fetchUserDataAndProfileImage(for uid: String? = nil, completion: @escaping (String?, String?, [String: Any]?) -> Void) {
        let userId = uid ?? user?.uid
        guard let userId = userId else {
            completion(nil, nil, nil)
            return
        }
        
        let userManager = UserManager()
        userManager.fetchUserData(uid: userId) { error, snapshot in
            if let error = error {
                print(error)
                completion(nil, nil, nil)
                return
            }
            guard let dictionary = snapshot?.value as? [String: Any] else {
                completion(nil, nil, nil)
                return
            }
            let currentName = (dictionary[db_nickName] as? String) ?? "Unknown"
            let profileImageUrl = (dictionary["profileImageUrl"] as? String)
            completion(currentName, profileImageUrl, dictionary)
        }
    }
    
    private func confirmDelegates() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
    }
    
    private func setupMessageInputBar() {
        if user != nil {
            if isLocation == false {
                messageInputBar.inputTextView.tintColor = .systemGray
                messageInputBar.sendButton.setTitleColor(.systemGray, for: .normal)
                messageInputBar.inputTextView.placeholder = "타 지역에서는 보낼 수 없습니다."
            } else {
                messageInputBar.inputTextView.tintColor = ThemeColor.mainOrange
                messageInputBar.sendButton.setTitleColor(ThemeColor.mainOrange, for: .normal)
                messageInputBar.inputTextView.placeholder = "채팅을 입력해주세요!"
            }
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
        messageInputBar.setStackViewItems([addBarButtonItem], forStack: .left, animated: false)
    }
    
    private func insertNewMessage(_ message: Message) {
        messages.append(message)
        
        groupMessagesByDate()
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
                self?.preloadProfileImages(for: messages)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func preloadProfileImages(for messages: [Message]) {
        let uniqueSenderIds = Set(messages.map { $0.sender.senderId })
        
        uniqueSenderIds.forEach { senderId in
            guard imageCache[senderId] == nil else { return }
            fetchUserDataAndProfileImage(for: senderId) { [weak self] _, imageUrl, _ in
                if let profileImageUrl = imageUrl {
                    self?.profileImageUrls[senderId] = profileImageUrl
                    self?.messagesCollectionView.reloadData()  // Reload to update avatars
                }
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
                self.insertNewMessage(message)
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    @objc private func presentInputActionSheet() {
        
        if user != nil {
            if isLocation == false {
                showMessage(title: "안내", message: "타 지역에서는 불가합니다.")
            } else {
                let actionSheet = UIAlertController(title: "유형을 선택해주세요", message: "아래에서 선택해주세요", preferredStyle: .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "카메라", style: .default, handler: {[weak self] _ in
                    self?.didTapCameraButton()
                }))
                actionSheet.addAction(UIAlertAction(title: "사진", style: .default, handler: { [weak self] _ in
                    self?.didTapLibraryButton()
                }))
                
                actionSheet.addAction(UIAlertAction(title: "지도", style: .default, handler: { [weak self] _ in
                    self?.presentLocationPicker()
                }))
                actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                
                present(actionSheet, animated: true)
            }
        } else if customUser != nil {
            showMessageWithCancel(title: "로그인이 필요한 기능입니다.", message: "확인을 클릭하시면 로그인 페이지로 이동합니다.") {
                let scene = UIApplication.shared.connectedScenes.first
                if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    sd.switchToGreetingViewController()
                }
            }
        }
        
    }
    
    private func presentLocationPicker() {
        let mapVC = MapViewController()
        mapVC.delegate = self
        mapVC.isLocationPicker = true
        let navController = UINavigationController(rootViewController: mapVC)
        present(navController, animated: true)
    }
    
    
    private func didTapLibraryButton() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    private func didTapCameraButton() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            present(picker, animated: true)
        } else {
            showMessage(title: "권한 설정 오류", message: "카메라를 사용하기 위해 권한을 설정해주세요!", completion: didTapLibraryButton)
        }
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! MessageContentCell
        let message = messages[indexPath.section]
//        cell.messageTimestampLabel.attributedText = messageTimestampLabelAttributedText(for: message, at: indexPath)
        configureAvatarView(cell.avatarView, for: message, at: indexPath, in: collectionView as! MessagesCollectionView)
        return cell
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
        return sortedDates.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let date = sortedDates[indexPath.section]
        return messagesByDate[date]![indexPath.item]
    }
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        let date = sortedDates[section]
        return messagesByDate[date]!.count
    }
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                                                             .foregroundColor: UIColor(white: 0.3, alpha: 1)])
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // 섹션의 첫 번째 아이템일 경우에만 날짜를 표시
        if indexPath.item == 0 {
            let date = sortedDates[indexPath.section]
            let dateString = formatDate(date)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ]
            
            return NSAttributedString(string: dateString, attributes: attributes)
        } else {
            // 섹션의 첫 번째 메시지가 아닌 경우 빈 헤더 반환
            return nil
        }
    }
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        //        self.showMessageTimestampOnSwipeLeft = true
        let messageDate = message.sentDate
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let dateString = formatter.string(from: messageDate)
        return
        NSAttributedString(string: dateString, attributes: [.font: UIFont.systemFont(ofSize: 12)])
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
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            return 16
        }
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
            return CGSize(width: messagesCollectionView.bounds.width, height: 10)
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
    func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일"
            return formatter.string(from: date)
        }
    func avatarFor(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageKit.Avatar {
        let sender = message.sender
        let initials = String(sender.displayName.prefix(2))
        
        if let cachedImage = imageCache[sender.senderId] {
            return MessageKit.Avatar(image: cachedImage, initials: initials)
        } else {
            // Preloaded images should already be in the cache if available
            return MessageKit.Avatar(initials: initials)
        }
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    private func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        guard let imageUrl = URL(string: url) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        let initials = String(sender.displayName.prefix(2))
        
        // 다른 사용자의 프로필 이미지 설정
        if let imageUrl = profileImageUrls[sender.senderId], let url = URL(string: imageUrl) {
            avatarView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    self.imageCache[sender.senderId] = value.image
                    DispatchQueue.main.async {
                        avatarView.set(avatar: MessageKit.Avatar(image: value.image, initials: initials))
                    }
                case .failure(let error):
                    print("Error downloading image: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        avatarView.set(avatar: MessageKit.Avatar(initials: initials))
                    }
                }
            }
        } else {
            avatarView.set(avatar: MessageKit.Avatar(initials: initials))
        }
    }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            return messageTimestampLabelAttributedText(for: message, at: indexPath)
        }
    
}

extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        Message.fetchDisplayName(userManager: UserManager()) { [weak self] displayName in
            guard let displayName = displayName, let self = self else {
                self?.showMessageWithCancel(title: "로그인이 필요한 기능입니다.", message: "확인을 클릭하시면 로그인 페이지로 이동합니다.", completion: {
                    let scene = UIApplication.shared.connectedScenes.first
                    if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                        sd.switchToGreetingViewController()
                    }
                })
                return
            }
            
            if isLocation == false {
                showMessage(title: "안내", message: "타 지역에서는 불가합니다.")
            } else {
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
}

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            showImageConfirmationAlert(image, picker: picker)
        } else if let asset = info[.phAsset] as? PHAsset {
            let imageSize = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: imageSize,
                                                  contentMode: .aspectFit,
                                                  options: nil) { [weak self] image, _ in
                guard let self = self, let image = image else { return }
                DispatchQueue.main.async {
                    self.showImageConfirmationAlert(image, picker: picker)
                }
            }
        }
    }

    private func showImageConfirmationAlert(_ image: UIImage, picker: UIImagePickerController) {
        let alert = UIAlertController(title: "이미지 업로드", message: "이 이미지를 업로드하시겠습니까?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            picker.dismiss(animated: true) {
                self?.sendPhoto(image)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        picker.present(alert, animated: true, completion: nil)
    }
    
    private func sendPhoto(_ image: UIImage) {
        guard !isSendingPhoto else { return }
        isSendingPhoto = true
        
        ProgressHUD.animate()

        _ = FirebaseStorageManager.uploadImage(image: image, channel: channel, progress: { progress in
            // 업로드 진행 상황을 처리할 수 있습니다. 예: progress bar 업데이트
            print("Upload progress: \(progress * 100)%")
        }, completion: { [weak self] result in
            self?.isSendingPhoto = false
            guard let self = self else { return }
            
            ProgressHUD.dismiss()
            
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
                ProgressHUD.dismiss()
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ChatVC: MapViewControllerDelegate {
    
    func didSelectLocation(_ location: CLLocationCoordinate2D) {
        // 현재 사용자를 가져옵니다.
        guard let user = self.user else {
            print("No valid user found")
            return
        }
        
        let displayName = currentDisplayName
        
        let locationMessage = Message(user: user, location: CLLocation(latitude: location.latitude, longitude: location.longitude), displayName: displayName)
        
        // Firestore에 저장
        chatFirestoreStream.save(locationMessage) { error in
            if let error = error {
                print(error)
                return
            }
            
            // 메시지를 추가하지 않음. Firestore의 스냅샷 리스너가 이를 처리함.
            // Firestore에 저장 후 리스너가 업데이트를 감지하여 메시지를 추가하게 됩니다.
        }
    }
}
extension MessageCollectionViewCell {
    @objc func block(_ sender: Any?) {
        // CollectionView 가져오기
        if let collectionView = self.superview as? UICollectionView {
            // IndexPath 가져오기
            if let indexPath = collectionView.indexPath(for: self) {
                // 액션 트리거
                collectionView.delegate?.collectionView?(collectionView, performAction: #selector(MessageCollectionViewCell.block(_:)), forItemAt: indexPath, withSender: sender)
            }
        }
    }
    
    @objc func report(_ sender: Any?) {
        // CollectionView 가져오기
        if let collectionView = self.superview as? UICollectionView {
            // IndexPath 가져오기
            if let indexPath = collectionView.indexPath(for: self) {
                // 액션 트리거
                collectionView.delegate?.collectionView?(collectionView, performAction: #selector(MessageCollectionViewCell.report(_:)), forItemAt: indexPath, withSender: sender)
            }
        }
    }
}
