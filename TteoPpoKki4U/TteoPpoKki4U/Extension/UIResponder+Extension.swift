//
//  UIResponder+Extension.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/7/24.
//

import UIKit

extension UIResponder {
    var currentViewController: UIViewController? {
        return next as? UIViewController ?? next?.currentViewController
    }
}
