//
//  MyPageViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/28/24.
//

import UIKit
import SnapKit
import Combine
import FirebaseAuth
import Kingfisher

class MyPageViewController: UIViewController {
    
    lazy var myPageView: MyPageView = {
        let view = MyPageView()
        view.editTapped = editTapped
        return view
    }()
    
    let myPageVM = MyPageViewModel()
    let userManager = UserManager()
    let reviewViewModel = ReviewViewModel()
    
    private var signVM: SignViewModel!
    private var signOutTapped: (() -> Void)!
    private var editTapped: (() -> Void)!
    
    private var cancellables = Set<AnyCancellable>()
    private var currentImageUrl: String?
    public var currentName: String?
    public var currentRank: String?
    
    convenience init(signOutTapped: @escaping () -> Void, editTapped:@escaping () -> Void, viewModel: SignViewModel) {
        self.init()
        self.signOutTapped = {
            DispatchQueue.main.async {
                signOutTapped()
            }
        }
        self.editTapped = editTapped
        self.signVM = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(myPageView)
        
        myPageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(16)
            make.leading.trailing.bottom.equalTo(view)
        }
        
        myPageView.collectionView.dataSource = self
        myPageView.collectionView.delegate = self
        // Register SeparatorView for the collection view
        myPageView.collectionView.register(SeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeparatorView.identifier)
        
        bind()
    }
    
    
    //아래는 이벤트씬뷰컨으로 이동하는 코드. 추천페이지의 이벤트이미지를 눌렀을때
    func showEventSceneViewController() {
        
        let eventPageVC = EventPageViewController()
        
        navigationController?.pushViewController(eventPageVC, animated: false) {
            eventPageVC.showEventSceneViewController()
        }
        
        //        let eventSceneVC = EventSceneViewController()
        //            navigationController?.pushViewController(eventSceneVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        fetchUser()
    }
    
    private func getData() {
        reviewViewModel.getUserReview { [unowned self] in
            switch reviewViewModel.userReview.count {
            case 0...4:
                currentRank = "떡볶이 순례길의 초행자"
            case 5...9:
                currentRank = "떡볶길을 자유 여행하는 탐방자"
            case 10...29:
                currentRank = "떡볶길의 베테랑 탐험자"
            case 30...49:
                currentRank = "떡볶이 순례길의 지휘관"
            default:
                currentRank = "떡볶이의 모든 것을 통찰하는 대가"
            }

            myPageView.userRankLabel.text = currentRank
        }
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
            myPageView.userNameLabel.text = currentName
        }
    }
    
    private func bind() {
        signVM.logoutPublisher
            .sink { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        let scene = UIApplication.shared.connectedScenes.first
                        if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                            sd.switchToGreetingViewController()
                        }
                    case .failure(let error):
                        self?.showMessage(title: "에러 발생", message: "\(error.localizedDescription)이 발생했습니다.")
                    }
                }
            }.store(in: &cancellables)
    }
    
}

extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return myPageVM.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPageVM.sections[section].options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPageCollectionViewCell.identifier, for: indexPath) as! MyPageCollectionViewCell
        var option = myPageVM.sections[indexPath.section].options[indexPath.item]
        if let _ = Auth.auth().currentUser {
            cell.configure(with: option)
        } else {
            if option.title == "로그아웃" {
                option.title = "로그인 하러가기"
            }
            cell.configure(with: option)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch indexPath {
        case [0, 0]:
            //showMessage(title: "안내", message: "해당 기능이 준비중입니다.")
            let NoticeTVC = NoticeTableViewController()
            navigationController?.pushViewController(NoticeTVC, animated: true)
        case [1, 0]:
            if let _ = Auth.auth().currentUser {
                let MyScrapVC = MyScrapViewController()
                navigationController?.pushViewController(MyScrapVC, animated: true)
            } else {
                showMessageWithCancel(title: "로그인이 필요한 기능입니다.", message: "확인을 클릭하시면 로그인 페이지로 이동합니다.") {
                    let scene = UIApplication.shared.connectedScenes.first
                    if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                        sd.switchToGreetingViewController()
                    }
                }
            }
        case [1, 1]:
            if let _ = Auth.auth().currentUser {
                let MyReviewVC = MyReviewViewController()
                navigationController?.pushViewController(MyReviewVC, animated: true)
            } else {
                showMessageWithCancel(title: "로그인이 필요한 기능입니다.", message: "확인을 클릭하시면 로그인 페이지로 이동합니다.") {
                    let scene = UIApplication.shared.connectedScenes.first
                    if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                        sd.switchToGreetingViewController()
                    }
                }
            }
            
        case [2, 0]:
            var isLogin = false
            if let _ = Auth.auth().currentUser {
                isLogin = true
            } else {
                isLogin = false
            }
            
            let settingVC = SettingViewController()
            settingVC.isLogin = isLogin
            navigationController?.pushViewController(settingVC, animated: true)
        case [2, 1]:
            if let _ = Auth.auth().currentUser {
                showMessageWithCancel(title: "로그아웃", message: "정말로 로그아웃 하시겠습니까?") { [weak self] in
                    DispatchQueue.main.async {
                        self?.signOutTapped!()
                    }
                }
            } else {
                signOutTapped!()
            }
            
            
        case [0, 1]:
            let EventVC = EventPageViewController()
            navigationController?.pushViewController(EventVC, animated: true)
            
        default:
            return
        }
    }
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 0.5) // 헤더 높이
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SeparatorView.identifier, for: indexPath) as! SeparatorView
            return header
        }
        return UICollectionReusableView()
    }
}

//push한 다음에도 계속 push할 수 있도록 해주는 기능(컴플리션)
extension UINavigationController {
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        pushViewController(viewController, animated: animated)
        
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
}
