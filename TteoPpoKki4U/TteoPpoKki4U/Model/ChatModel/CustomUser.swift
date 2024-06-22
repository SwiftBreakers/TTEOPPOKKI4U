//
//  CustomUser.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/22/24.
//

import FirebaseAuth

struct CustomUser {
    let uid: String
    let email: String?
    let isGuest: Bool
    
    init(guestUID: String) {
        self.uid = guestUID
        self.email = nil
        self.isGuest = true
    }
}
