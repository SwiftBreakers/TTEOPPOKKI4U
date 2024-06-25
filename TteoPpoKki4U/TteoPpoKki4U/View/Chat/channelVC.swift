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

class ChannelVC: BaseViewController {
    
    let uid: String
    let userManager = UserManager()
    var currentName: String?
    let myPageView = MyPageView()
    
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
        
        checkNickname()
        configureViews()
//        addToolBarItems()
        setupListener()
        checkUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = ThemeColor.mainOrange
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: ThemeColor.mainOrange
        ]
        checkUserLocation()
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
                }
            }
        }
    }
    
    private func showNameAlert(uid: String) {
        let alertController = UIAlertController(title: "Enter Name", message: "Please enter your name.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            if let textField = alertController.textFields?.first, let newName = textField.text, !newName.isEmpty {
                self?.updateUserName(uid: uid, newName: newName)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
    
//    private func addToolBarItems() {
//        toolbarItems = [
//            UIBarButtonItem(title: "로그아웃", style: .plain, target: self, action: #selector(didTapSignOutItem)),
//            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddItem))
//        ]
//        navigationController?.isToolbarHidden = false
//    }
    
    private func setupListener() {
        channelStream.subscribe { [weak self] result in
            switch result {
            case .success(let data):
                self?.updateCell(to: data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
//    @objc private func didTapSignOutItem() {
//        showAlert(message: "로그아웃 하시겠습니까?",
//                  cancelButtonName: "취소",
//                  confirmButtonName: "확인",
//                  confirmButtonCompletion: {
//            do {
//                try Auth.auth().signOut()
//            } catch {
//                print("Error signing out: \(error.localizedDescription)")
//            }
//        })
//    }
//    
//    @objc private func didTapAddItem() {
//        showAlert(title: "새로운 채널 생성",
//                  cancelButtonName: "취소",
//                  confirmButtonName: "확인",
//                  isExistsTextField: true,
//                  confirmButtonCompletion: { [weak self] in
//            self?.channelStream.createChannel(with: self?.alertController?.textFields?.first?.text ?? "")
//        })
//    }
    
    // MARK: - Update Cell
    
    private func updateCell(to data: [(Channel, DocumentChangeType)]) {
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
    }
    
    private func addChannelToTable(_ channel: Channel) {
        guard channels.contains(channel) == false else { return }
        
        channels.append(channel)
        channels.sort()
        
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        let viewController: ChatVC
        
        if currentAddress != channel.name {
            isLocation = false
        } else {
            isLocation = true
        }
        
        if let user = currentUser {
            viewController = ChatVC(user: user, channel: channel)
            viewController.isLocation = isLocation
        } else if let customUser = customUser {
            viewController = ChatVC(customUser: customUser, channel: channel)
        } else {
            fatalError("No valid user found.")
        }
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChannelVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            getAddress(coordinate: userLocation)
            locationManager.stopUpdatingLocation()  // 위치 업데이트 멈추기
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func getAddress(coordinate: CLLocation) {
        let address = CLGeocoder.init()
        
        address.reverseGeocodeLocation(coordinate) { [weak self] (placeMarks, error) in
            var placeMark: CLPlacemark!
            placeMark = placeMarks?[0]
            
            guard let address = placeMark else { return }
            self?.currentAddress = address.administrativeArea!
        }
        
    }
    
}
