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
    
    let eventContainerView = UIView()
    let eventContainerSubView = UIView()
    let eventContainerSubImageView = UIView()
    let closeButton = UIButton(type: .system)
    let doNotShowTodayButton = UIButton(type: .system)
    let eventImageView = UIImageView()
    let titleLabel = UILabel()
    
    let subTitleLabel = UILabel()
    
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
        
        //아래꺼 추가-이벤트오버레이
        setupEventOverlay()
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


extension MyPageViewController {

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 저장된 날짜와 현재 날짜 비교
        if shouldShowEvent() {
            showEventOverlay()
        }
    }
    
    func setupEventOverlay() {
        eventContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        eventContainerView.isHidden = true
        view.addSubview(eventContainerView)
        eventContainerView.addSubview(eventContainerSubView)
        eventContainerSubView.backgroundColor = UIColor.white
        eventContainerSubView.layer.cornerRadius = 4
        eventContainerSubView.addSubview(eventContainerSubImageView)
        eventContainerView.addSubview(titleLabel)
        eventContainerView.addSubview(subTitleLabel)
        
        eventContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        eventContainerSubView.snp.makeConstraints { make in
            make.center.equalToSuperview()
//            make.top.equalToSuperview().offset(200)
//            make.leading.equalToSuperview().offset(50)
            make.height.equalTo(300)
            make.width.equalTo(250)
        }
        
        eventContainerSubImageView.clipsToBounds = true
        eventContainerSubImageView.snp.makeConstraints { make in
            make.top.equalTo(eventContainerSubView.snp.top).offset(15)
            make.centerX.equalTo(eventContainerSubView)
//            make.top.equalToSuperview().offset(200)
//            make.leading.equalToSuperview().offset(50)
            make.height.equalTo(220)
            make.width.equalTo(220)
        }
        
        
        let eventImageView = UIImageView(image: UIImage(named: "sample"))
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.clipsToBounds = true
        eventContainerSubImageView.addSubview(eventImageView)
        
        eventImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(eventImageTapped))
                eventImageView.isUserInteractionEnabled = true
                eventImageView.addGestureRecognizer(tapGesture)
        
        titleLabel.text("리뷰 쓰고 커피 받아가세요!")
        titleLabel.font = ThemeFont.fontMedium(size: 14)

        titleLabel.textColor = UIColor(hexString: "353535")
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(eventContainerSubImageView.snp.bottom).offset(10)
//            make.leading.equalTo(eventContainerSubImageView.snp.leading).offset(10)
//            make.trailing.equalTo(eventContainerSubImageView.snp.trailing).offset(10)
            make.centerX.equalTo(eventContainerSubView)
        }
        
        subTitleLabel.text("기간 종료 후 20명 순차지급")
        subTitleLabel.font = ThemeFont.fontRegular(size: 12)

        subTitleLabel.textColor = UIColor(hexString: "353535")
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
//            make.leading.equalTo(titleLabel.snp.leading)
            make.centerX.equalTo(titleLabel)
        }
        
        closeButton.setTitle("닫기", for: .normal)
        closeButton.titleLabel?.font = ThemeFont.fontMedium(size: 14)
        closeButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
        closeButton.backgroundColor = UIColor(hexString: "FE724C")
        closeButton.layer.cornerRadius = 4
        closeButton.addTarget(self, action: #selector(hideEventOverlay), for: .touchUpInside)
        eventContainerView.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalTo(eventContainerSubView.snp.trailing)
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.top.equalTo(eventContainerSubView.snp.bottom).offset(10)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        doNotShowTodayButton.setTitle("오늘 하루 보지 않기", for: .normal)
        doNotShowTodayButton.titleLabel?.font = ThemeFont.fontRegular(size: 14)
        doNotShowTodayButton.setTitleColor(UIColor(hexString: "353535"), for: .normal)
        doNotShowTodayButton.backgroundColor = .white
        doNotShowTodayButton.layer.cornerRadius = 4
        doNotShowTodayButton.addTarget(self, action: #selector(doNotShowTodayButtonTapped), for: .touchUpInside)
        eventContainerView.addSubview(doNotShowTodayButton)
        
        doNotShowTodayButton.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton.snp.centerY)
            make.leading.equalTo(eventContainerSubView.snp.leading)
            make.width.equalTo(180)
            make.height.equalTo(40)
        }
    }
    
    @objc func eventImageTapped() {
        if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 3 // MyPageViewController가 탭바의 네번째에 있음
                    
                    if let myPageNavController = tabBarController.viewControllers?[3] as? UINavigationController,
                       let myPageVC = myPageNavController.viewControllers.first as? MyPageViewController {
                        myPageVC.showEventSceneViewController()
                        
                        
                    }
                }
    }
    
    func showEventOverlay() {
        eventContainerView.isHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc func hideEventOverlay() {
        eventContainerView.isHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc func doNotShowTodayButtonTapped() {
        let currentDate = Date()
        let userID = Auth.auth().currentUser?.uid ?? "guest" // Firebase Authentication을 사용하여 현재 사용자의 ID를 가져옵니다.
                    UserDefaults.standard.set(currentDate, forKey: "DoNotShowEventDate_\(userID)") // 사용자별로 날짜를 저장합니다.
                
        hideEventOverlay()
    }
    
    func shouldShowEvent() -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
//        if let savedDate = UserDefaults.standard.object(forKey: "DoNotShowEventDate") as? Date {
//            if calendar.isDate(currentDate, inSameDayAs: savedDate) {
//                return false
//            }
//        }
        let userID = Auth.auth().currentUser?.uid ?? "guest" // Firebase Authentication을 사용하여 현재 사용자의 ID를 가져오기
                  if let savedDate = UserDefaults.standard.object(forKey: "DoNotShowEventDate_\(userID)") as? Date { // 사용자별로 날짜를 불러오기
                    if calendar.isDate(currentDate, inSameDayAs: savedDate) {
                        return false
                    }
                }
        
        return true
    }
}
