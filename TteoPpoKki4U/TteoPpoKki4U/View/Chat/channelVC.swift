//
//  channelVC.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/20.
//

import UIKit
import SnapKit
import FirebaseAuth
import Firebase
import CoreLocation
import Combine

class ChannelVC: BaseViewController {
    
    let uid: String
    let userManager = UserManager()
    var currentName: String?
    let myPageView = MyPageView()
    var documentCounts: [String: Int] = [:]
    
    lazy var channelTableView: UITableView = {
        let view = UITableView()
        view.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.className)
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    var channels = [Channel]()
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    var userLocation: CLLocation = CLLocation()
    private var currentUser: User?
    private var customUser: CustomUser?
    private let channelStream = ChannelFirestoreStream()
    private var currentChannelAlertController: UIAlertController?
    private var currentAddress = ""
    private var isLocation = false
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel: ManageViewModel?
    var isValidate = false
    
    init(currentUser: User) {
        self.currentUser = currentUser
        self.customUser = nil
        self.uid = currentUser.uid
        super.init(nibName: nil, bundle: nil)
        
        //title = "Channels"
    }
    
    init(customUser: CustomUser) {
        self.currentUser = nil
        self.customUser = customUser
        self.uid = customUser.uid
        super.init(nibName: nil, bundle: nil)
        
        //title = "Channels"
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        channelStream.removeListener()
        currentUser = nil
        customUser = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        channelTableView.backgroundColor = .white
        configureViews()
        //addToolBarItems()
        checkUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = ThemeColor.mainOrange
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: ThemeColor.mainOrange
        ]
        if Auth.auth().currentUser == nil {
            currentUser = nil
            customUser = CustomUser(guestUID: "guest")
        }
        checkNickname()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateVisibleCells() // Move this call here
    }
    
    
    
    private func validateNickname(nickName: String, completion: @escaping ((Bool) -> Void)) {
        let manageManager = ManageManager()
        self.viewModel = ManageViewModel(manageManager: manageManager)
        
        self.viewModel?.getUsers {
            if self.viewModel?.userArray.contains(where: { $0.nickName == nickName }) == false {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func checkUserLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func checkNickname() {
        // 유저 모드일 때만 닉네임 확인
        if let user = currentUser {
            userManager.fetchUserData(uid: user.uid) { [self] error, snapshot in
                if let error = error {
                    print(error)
                }
                guard let dictionary = snapshot?.value as? [String: Any] else { return }
                currentName = (dictionary[db_nickName] as? String) ?? "Unknown"
                if currentName == ""  {
                    showNameAlert(uid: user.uid)
                    isValidate = false
                } else {
                    isValidate = true
                }
            }
        }
    }
    
    private func showNameAlert(uid: String) {
        let alertController = UIAlertController(title: "닉네임 입력", message: "개성넘치는 닉네임을 입력해주세요!",
                                                preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "닉네임 입력"
        }
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] (_) in
            if let textField = alertController.textFields?.first, let newName = textField.text, !newName.isEmpty {
                self?.validateNickname(nickName: newName) { result in
                    switch result {
                    case true:
                        self?.updateUserName(uid: uid, newName: newName)
                        self?.isValidate = true
                    case false:
                        self?.isValidate = false
                        self?.showMessage(title: "중복 확인", message: "현재 닉네임은 이미 존재합니다.") {
                            self?.showNameAlert(uid: uid) // 이름이 유효하지 않으면 알림을 다시 표시
                        }
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func updateUserName(uid: String, newName: String) {
        let ref = Database.database().reference().child("users/\(uid)")
        ref.updateChildValues([db_nickName: newName]) { [weak self] (error, ref) in
            if let error = error {
                print("Failed to update name:", error)
                return
            }
            self?.currentName = newName
            self?.myPageView.userNameLabel.text = newName
            print("Successfully updated name to \(newName)")
        }
    }
    
    private func configureViews() {
        
        view.addSubview(channelTableView)
        channelTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func addToolBarItems() {
        toolbarItems = [
            UIBarButtonItem(title: "로그아웃", style: .plain, target: self, action: #selector(didTapSignOutItem)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddItem))
        ]
        navigationController?.isToolbarHidden = false
    }
    
    private func setupListener() {
        channelStream.subscribe { [weak self] result in
            switch result {
            case .success(let data):
                self?.updateCell(to: data) { [weak self] in
                    self?.fetchDocumentCounts()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchDocumentCounts() {
        let group = DispatchGroup()
        
        for channel in channels {
            guard let channelId = channel.id else { continue }
            group.enter()
            getDocumentCount(id: channelId) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let count):
                    self.documentCounts[channelId] = count
                case .failure(let error):
                    print("Error fetching document count: \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.channelTableView.reloadData()
        }
    }
    
    @objc private func didTapSignOutItem() {
        showAlert(message: "로그아웃 하시겠습니까?",
                  cancelButtonName: "취소",
                  confirmButtonName: "확인",
                  confirmButtonCompletion: {
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        })
    }
    
    @objc private func didTapAddItem() {
        showAlert(title: "새로운 채널 생성",
                  cancelButtonName: "취소",
                  confirmButtonName: "확인",
                  isExistsTextField: true,
                  confirmButtonCompletion: { [weak self] in
            self?.channelStream.createChannel(with: self?.alertController?.textFields?.first?.text ?? "")
        })
    }
    
    // MARK: - Update Cell
    
    private func updateCell(to data: [(Channel, DocumentChangeType)], completion: @escaping () -> Void) {
        data.forEach { (channel, documentChangeType) in
            switch documentChangeType {
            case .added:
                addChannelToTable(channel)
            case .modified:
                updateChannelInTable(channel)
            case .removed:
                removeChannelFromTable(channel)
            }
        }
        
        completion()
    }
    
    private func addChannelToTable(_ channel: Channel) {
        guard channels.contains(channel) == false else { return }
        
        channels.append(channel)
        
        // currentAddress와 일치하는 채널을 찾음
        if let currentAddressIndex = channels.firstIndex(where: { $0.name == currentAddress }) {
            let currentAddressChannel = channels.remove(at: currentAddressIndex)
            channels.sort(by: { $0.name < $1.name }) // 나머지 채널 이름 기준으로 정렬
            channels.insert(currentAddressChannel, at: 0) // currentAddress 채널을 맨 앞에 삽입
        } else {
            channels.sort(by: { $0.name < $1.name }) // 나머지 채널 이름 기준으로 정렬
        }
        
        guard let index = channels.firstIndex(of: channel) else { return }
        channelTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateChannelInTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else { return }
        channels[index] = channel
        channelTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChannelFromTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else { return }
        channels.remove(at: index)
        channelTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func updateVisibleCells() {
        guard let visibleIndexPaths = channelTableView.indexPathsForVisibleRows else { return }
        
        for indexPath in visibleIndexPaths {
            guard let channelId = channels[indexPath.row].id else { continue }
            
            getDocumentCount(id: channelId) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let count):
                        self.documentCounts[channelId] = count
                        if let cell = self.channelTableView.cellForRow(at: indexPath) as? ChannelTableViewCell {
                            self.updateCellCountLabel(cell, with: count)
                        }
                    case .failure(let error):
                        print("Error fetching document count: \(error)")
                        if let cell = self.channelTableView.cellForRow(at: indexPath) as? ChannelTableViewCell {
                            self.updateCellCountLabel(cell, with: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    private func updateCellCountLabel(_ cell: ChannelTableViewCell, with count: Int?) {
        if let count = count {
            if count >= 10 {
                cell.threadCountLabel.text = "10+"
                cell.countView.isHidden = false
            } else if count == 0 {
                cell.threadCountLabel.text = ""
                cell.countView.isHidden = true
            } else {
                cell.threadCountLabel.text = "\(count)"
                cell.countView.isHidden = false
            }
        } else {
            cell.threadCountLabel.text = "Error"
            cell.countView.isHidden = false
        }
    }
    
}

extension ChannelVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.className, for: indexPath) as! ChannelTableViewCell
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        cell.chatRoomLabel.text = channels[indexPath.row].name
        cell.threadCountLabel.text = "..."
        //cell.countView.isHidden = true
        
        if channels[indexPath.row].name == currentAddress {
            cell.myLabel.text = "현재 지역"
        }
        
        if let channelId = channels[indexPath.row].id {
            if let count = documentCounts[channelId] {
                updateCellCountLabel(cell, with: count)
            } else {
                getDocumentCount(id: channelId) { [weak self] result in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let count):
                            self.documentCounts[channelId] = count
                            if let updateCell = tableView.cellForRow(at: indexPath) as? ChannelTableViewCell {
                                self.updateCellCountLabel(updateCell, with: count)
                            }
                        case .failure(let error):
                            print("Error fetching document count: \(error)")
                            if let updateCell = tableView.cellForRow(at: indexPath) as? ChannelTableViewCell {
                                self.updateCellCountLabel(updateCell, with: nil)
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func getDocumentCount(id: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let streamPath = "channels/\(id)/thread"
        
        // Firestore 인스턴스 가져오기
        let firestoreDataBase = Firestore.firestore()
        
        firestoreDataBase.collection(streamPath).whereField(db_isActive, isEqualTo: true).getDocuments { (snapshot, error) in
            if let error = error {
                // 에러 발생 시 실패를 반환
                completion(.failure(error))
            } else {
                // 성공 시 도큐먼트 수를 반환
                if let snapshot = snapshot {
                    let documentCount = snapshot.documents.count
                    completion(.success(documentCount))
                } else {
                    // Snapshot이 nil인 경우도 에러로 처리
                    completion(.failure(NSError(domain: "FirestoreErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Snapshot is nil"])))
                }
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateVisibleCells()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateVisibleCells()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channel = channels[indexPath.row]
        var viewController: ChatVC? // viewController를 옵셔널로 선언
        
        if currentAddress != channel.name {
            isLocation = false
        } else {
            isLocation = true
        }
        
        if let user = currentUser {
            if isValidate {
                viewController = ChatVC(user: user, channel: channel)
                viewController?.isLocation = isLocation
            } else {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                showNameAlert(uid: uid)
                return // 이름 확인이 완료될 때까지 반환하여 viewController 초기화를 기다림
            }
        } else if let customUser = customUser {
            viewController = ChatVC(customUser: customUser, channel: channel)
        } else {
            fatalError("No valid user found.")
        }
        
        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChannelVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            getAddress(coordinate: userLocation) { [weak self] address in
                guard let self = self else { return }
                self.currentAddress = address ?? ""
                self.locationManager.stopUpdatingLocation()  // 위치 업데이트 멈추기
                self.setupListener()  // currentAddress가 설정된 후 setupListener 호출
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func getAddress(coordinate: CLLocation, completion: @escaping (String?) -> Void) {
        let address = CLGeocoder.init()
        
        address.reverseGeocodeLocation(coordinate) { (placeMarks, error) in
            var placeMark: CLPlacemark!
            placeMark = placeMarks?[0]
            
            guard let address = placeMark else {
                completion(nil)
                return
            }
            completion(address.administrativeArea)
        }
    }
    
}
