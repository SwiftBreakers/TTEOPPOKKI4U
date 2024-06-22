//
//  UIImageView+Extension.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/23/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    private struct AssociatedKeys {
        static var urlKey = "urlKey"
    }
    
    var imageURL: URL? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.urlKey) as? URL
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
