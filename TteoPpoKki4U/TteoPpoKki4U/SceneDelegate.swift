//
//  SceneDelegate.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var currentUser: User?
    private lazy var signManager = SignManager()
    private lazy var userManager = UserManager()
    private lazy var signViewModel = SignViewModel(signManager: signManager)
    private lazy var manageManager = ManageManager()
    private lazy var manageViewModel = ManageViewModel(manageManager: manageManager)
    private lazy var greetingVC = GreetingViewController()
    private lazy var manageVC = ManageViewController(viewModel: manageViewModel)
    private lazy var tabbarDelegate = TabbarControllerDelegate()
    private lazy var personalInfoVC = PersonalInfoViewController()
    private lazy var mypageVC = UINavigationController(rootViewController: MyPageViewController())
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        Thread.sleep(forTimeInterval: 0.5)
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        
        let loadingVC = UIViewController()
        loadingVC.view.backgroundColor = .white // 로딩 화면 배경색 설정
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loadingVC.view.center
        activityIndicator.startAnimating()
        loadingVC.view.addSubview(activityIndicator)
        
        window.rootViewController = loadingVC
        window.makeKeyAndVisible()
        
        configureInitialViewController()
    }
    
    func configureInitialViewController() {
        if let user = Auth.auth().currentUser {
            signViewModel.checkUserisBlock(uid: user.uid) { [weak self] isBlock in
                if isBlock {
                    DispatchQueue.main.async {
                        self?.switchToGreetingViewController()
                        self?.greetingVC.showMessage(title: "차단 알림", message: "현재 계정은 차단되었습니다.\n관리자에게 문의하세요")
                        self?.signViewModel.signOut {
                            DispatchQueue.main.async {
                                self?.switchToGreetingViewController()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.switchToMainTabBarController()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.switchToGreetingViewController()
            }
        }
    }
    
    func switchToMainTabBarController() {
        let user: User? = Auth.auth().currentUser
            let customUser: CustomUser?
            
            if let user = user {
                currentUser = user
                customUser = nil
            } else {
                customUser = CustomUser(guestUID: "guest")
            }
        
        let tabbarController = UITabBarController()
        
        greetingVC = GreetingViewController(
            appleTapped: { [weak signViewModel] in
                signViewModel?.appleLoginDidTapped()
            },
            googleTapped: { [weak signViewModel] in
                signViewModel?.googleLoginDidTapped(presentViewController: self.greetingVC)},
            hiddenTapped: {
                self.greetingVC.generate(completion: { bool in
                    if bool {
                        self.greetingVC.present(self.manageVC, animated: true)
                    }
                })
            }, guestTapped: {
                self.switchToMainTabBarController()
            },
            viewModel: signViewModel)
        
        let mapVC = UINavigationController(rootViewController: MapViewController())
        let recommendVC = UINavigationController(rootViewController: RecommendViewController())
        let communityVC: UINavigationController
            if let user = currentUser {
                communityVC = UINavigationController(rootViewController: ChannelVC(currentUser: user))
            } else if let guestUser = customUser {
                communityVC = UINavigationController(rootViewController: ChannelVC(customUser: guestUser))
            } else {
                fatalError("No valid user found.")
            }
        mypageVC = UINavigationController(rootViewController: MyPageViewController(signOutTapped: { [weak signViewModel, weak self] in
            signViewModel?.signOut {
                DispatchQueue.main.async {
                    self?.configureInitialViewController()
                }
            }
        }, editTapped: { [weak self] in
            guard let uid = user?.uid else { return }
            self?.userManager.fetchUserData(uid: uid) { [self] error, snapshot in
                guard let dictionary = snapshot?.value as? [String: Any] else { return }
                let currentImageUrl = dictionary[db_profileImageUrl] as? String
                let currentName = (dictionary[db_nickName] as? String) ?? "닉네임을 설정해주세요"
                self?.personalInfoVC.gotProfileImage = currentImageUrl
                self?.personalInfoVC.profileName = currentName
                self?.mypageVC.pushViewController(self!.personalInfoVC, animated: true)
            }
            
        }, viewModel: signViewModel))
        
        mapVC.tabBarItem = UITabBarItem(
            title: "지도",
            image: UIImage(systemName: "map.circle"),
            selectedImage: UIImage(systemName: "map.circle.fill"))
        recommendVC.tabBarItem = UITabBarItem(
            title: "추천",
            image: UIImage(systemName: "hand.thumbsup"),
            selectedImage: UIImage(systemName: "hand.thumbsup.fill"))
        communityVC.tabBarItem = UITabBarItem(
            title: "커뮤니티",
            image: UIImage(systemName: "person.3"),
            selectedImage: UIImage(systemName: "person.3.fill"))
        mypageVC.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        
        tabbarController.viewControllers = [recommendVC, mapVC, communityVC, mypageVC]
        
        window?.rootViewController = tabbarController
        tabbarController.tabBar.backgroundColor = .white
        tabbarController.tabBar.barTintColor = .white
        tabbarController.tabBar.tintColor = ThemeColor.mainOrange
        tabbarController.delegate = tabbarDelegate
    }
    
    func switchToGreetingViewController() {
        DispatchQueue.main.async { [self] in
            self.greetingVC = GreetingViewController(
                appleTapped: { [weak signViewModel] in
                    signViewModel?.appleLoginDidTapped()
                },
                googleTapped: { [weak signViewModel] in
                    signViewModel?.googleLoginDidTapped(presentViewController: self.greetingVC)},
                hiddenTapped: {
                    self.greetingVC.generate(completion: { bool in
                        if bool {
                            self.greetingVC.present(self.manageVC, animated: true)
                        }
                    })
                }, guestTapped: {
                    self.switchToMainTabBarController()
                },
                viewModel: signViewModel)
            self.window?.rootViewController = self.greetingVC
        }
    }
    
}
