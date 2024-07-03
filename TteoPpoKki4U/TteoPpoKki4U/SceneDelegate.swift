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
    var customUser: CustomUser? // 여기에서 var로 수정했습니다.
    private lazy var signManager = SignManager()
    private lazy var userManager = UserManager()
    private lazy var signViewModel = SignViewModel(signManager: signManager)
    private lazy var manageManager = ManageManager()
    private lazy var manageViewModel = ManageViewModel(manageManager: manageManager)
    private lazy var greetingVC: GreetingViewController = {
        let vc = GreetingViewController()
        vc.delegate = self
        return vc
    }()
    private lazy var manageVC = ManageViewController(viewModel: manageViewModel)
    private lazy var tabbarDelegate = TabbarControllerDelegate()
    private lazy var personalInfoVC = PersonalInfoViewController()
    private lazy var mypageVC = UINavigationController(rootViewController: MyPageViewController())
    private lazy var verifyVC = VerifyViewController()
    
    private var isVerifyVCBeingPresented = false
    private var isValidate = false
    private var isImageChanged = false
    
    
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
        
        if user != nil {
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
                self.customUser = CustomUser(guestUID: "guest") // guestTapped 시 customUser 설정
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
                self?.personalInfoVC.isValidate = self!.isValidate
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
                    self.customUser = CustomUser(guestUID: "guest") // guestTapped 시 customUser 설정
                    self.switchToMainTabBarController()
                },
                viewModel: signViewModel)
            self.window?.rootViewController = self.greetingVC
        }
    }
    
    func showVerifyVC() {
        verifyVC.modalPresentationStyle = .fullScreen

        // VerifyViewController가 이미 표시 중인지 확인하는 플래그를 사용
        if isVerifyVCBeingPresented {
            print("VerifyViewController is already being presented.")
            return
        }

        // 현재 표시된 뷰 컨트롤러를 가져옵니다.
        if let rootViewController = window?.rootViewController {
            // VerifyViewController가 이미 표시되지 않은 경우에만 표시합니다.
            if rootViewController.presentedViewController == verifyVC {
                print("VerifyViewController is already presented.")
            } else {
                isVerifyVCBeingPresented = true // 플래그 설정
                rootViewController.present(verifyVC, animated: true) { [weak self] in
                    self?.isVerifyVCBeingPresented = false // 프레젠테이션 완료 후 플래그 해제
                }
            }
        } else {
            // 루트 뷰 컨트롤러가 없을 경우 (예외적인 경우)
            isVerifyVCBeingPresented = true // 플래그 설정
            window?.rootViewController = verifyVC
            // verifyVC가 루트 뷰 컨트롤러로 설정된 후에도 플래그를 해제해야 합니다.
            isVerifyVCBeingPresented = false // 플래그 해제
        }
    }
    
}

extension SceneDelegate: GreetingViewControllerDelegate {
    func showVerifyViewController() {
        verifyVC.modalPresentationStyle = .fullScreen
        greetingVC.present(verifyVC, animated: true)
    }
}
