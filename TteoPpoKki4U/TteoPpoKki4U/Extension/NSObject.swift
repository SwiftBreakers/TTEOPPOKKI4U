//
//  NSObject.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/20.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
