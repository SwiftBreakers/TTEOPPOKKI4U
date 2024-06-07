//
//  SceneDelegate.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import KakaoSDKAuth
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private lazy var signManager = SignManager()
    private lazy var signViewModel = SignViewModel(signManager: signManager)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        configureInitialViewController()
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        var greetingVC = GreetingViewController()
        
        greetingVC = GreetingViewController(
            appleTapped: { [weak signViewModel] in
               signViewModel?.appleLoginDidTapped()
            }
            ,kakaoTapped: { [weak signViewModel] in
                signViewModel?.kakaoLoginDidTapped()
            }, googleTapped: { [weak signViewModel] in
                signViewModel?.googleLoginDidTapped(presentViewController: greetingVC)}
            , viewModel: signViewModel)
        
        self.window = window
        window.makeKeyAndVisible()
        
        // added
        let tabbarController = UITabBarController()
        let firstVC = UINavigationController(rootViewController: greetingVC)
        let mapVC = MapViewController()
        let recommendVC = RecommendViewController()
        let communityVC = CommunityViewController()
        let mypageVC = MyPageViewController(signOutTapped: { [weak signViewModel] in
            signViewModel?.signOut()
        }, viewModel: signViewModel)
        
        
        firstVC.tabBarItem = UITabBarItem(
            title: "로그인테스트",
            image: UIImage(systemName: "magnifyingglass.circle"),
            selectedImage: UIImage(systemName: "magnifyingglass.circle.fill"))
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
        tabbarController.viewControllers = [firstVC,recommendVC, mapVC, communityVC, mypageVC]
        window.rootViewController = tabbarController // modifed
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    
    func configureInitialViewController () {
            var initialVC = UIViewController()
            if Auth.auth().currentUser != nil {
                print(Auth.auth().currentUser?.uid)
            } else {
               print("nil")
            }
        }
}

