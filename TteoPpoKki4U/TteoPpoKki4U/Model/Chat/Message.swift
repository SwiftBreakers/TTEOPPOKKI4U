//
//  Message.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/7/24.
//

import UIKit
import Firebase

struct Message {
    let id: String
    let text: String
    let senderId: String
    let senderName: String
    let createdAt: Timestamp
}
