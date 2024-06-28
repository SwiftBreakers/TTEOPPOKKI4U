//
//  UserModel.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/3/24.
//

import Foundation

struct UserModel: Hashable {
    let uid: String
    let email: String
    let isBlock: Bool
    let nickName: String
    let profileImageUrl: String
    let isAgree: Bool
}
