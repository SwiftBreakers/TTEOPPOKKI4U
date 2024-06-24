//
//  TabbarControllerDelegate.swift
//  TteoPpoKki4U
//
//  Created by 김건응 on 6/24/24.
//

import Foundation
import UIKit

final class TabbarControllerDelegate: NSObject, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard
            let navigation = viewController as? UINavigationController,
            navigation.viewControllers.first as? MyPageViewController != .none
        else { return }
        
        navigation.popToRootViewController(animated: false)
    }
}
