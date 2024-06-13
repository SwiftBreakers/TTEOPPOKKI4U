//
//  MyPageViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import SnapKit
import Combine
import FirebaseAuth
import Kingfisher

class MyPageViewController: UIViewController {
    
    let myPageView = MyPageView()
    let myPageVM = MyPageViewModel()
    let userManager = UserManager()
    
    private var signVM: SignViewModel!
    private var signOutTapped: (() -> Void)!
    
    private var cancellables = Set<AnyCancellable>()
    private var currentImageUrl: String?
    private var currentName: String?
    
    convenience init(signOutTapped: @escaping () -> Void, viewModel: SignViewModel) {
        self.init()
        self.signOutTapped = signOutTapped
        self.signVM = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "마이페이지"
        
        view.addSubview(myPageView)
        
        myPageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(16)
            make.leading.trailing.bottom.equalTo(view)
        }
        
        myPageView.collectionView.dataSource = self
        myPageView.collectionView.delegate = self
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUser()
    }
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        userManager.fetchUserData(uid: uid) { [self] error, snapshot in
            if let error = error {
                print(error)
            }
            guard let dictionary = snapshot?.value as? [String: Any] else { return }
            myPageView.userProfile.kf.setImage(with: URL(string: dictionary[db_profileImageUrl] as! String))
            currentImageUrl = dictionary[db_profileImageUrl] as? String
            currentName = (dictionary[db_nickName] as? String) ?? "Unknown"
        }
    }
    
    private func bind() {
        signVM.logoutPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                return
            case .failure(let error):
                self?.showMessage(title: "에러 발생", message: "\(error.localizedDescription)이 발생했습니다.")
            }
        } receiveValue: { _ in
            let scene = UIApplication.shared.connectedScenes.first
            if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sd.switchToGreetingViewController()
            }
        }.store(in: &cancellables)
    }
}

extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return myPageVM.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPageVM.sections[section].options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPageCollectionViewCell.identifier, for: indexPath) as! MyPageCollectionViewCell
        let option = myPageVM.sections[indexPath.section].options[indexPath.item]
        cell.configure(with: option)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch indexPath {
        case [0, 0]:
            let personalInfoVC = PersonalInfoViewController()
            personalInfoVC.gotProfileImage = currentImageUrl
            personalInfoVC.profileName = currentName
            navigationController?.pushViewController(personalInfoVC, animated: true)
        case [1, 0]:
            let MyScrapVC = MyScrapViewController()
            
            navigationController?.pushViewController(MyScrapVC, animated: true)
        case [1, 1]:
            let MyReviewVC = MyReviewViewController()
            navigationController?.pushViewController(MyReviewVC, animated: true)
        case [2, 0]:
            let settingVC = SettingViewController()
            navigationController?.pushViewController(settingVC, animated: true)
        case [2, 1]:
            showMessageWithCancel(title: "로그아웃", message: "정말로 로그아웃 하시겠습니까?") { [weak self] in
                self?.signOutTapped!()
            }
        default:
            return
        }
    }
}


