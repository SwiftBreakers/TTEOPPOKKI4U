//
//  ReviewModel.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/8/24.
//

import Foundation
import Firebase

struct ReviewModel {
    
    var uid: String
    var title: String
    var storeAddress: String
    var storeName: String
    var content: String
    var rating: Float
    var imageURL: [String]
    var isActive: Bool
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
}
