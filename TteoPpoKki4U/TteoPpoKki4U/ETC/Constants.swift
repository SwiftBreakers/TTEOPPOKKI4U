//
//  Constants.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/8/24.
//

import Foundation
import FirebaseFirestore

let reviewCollection = Firestore.firestore().collection("UserReview")

let db_uid = "uid"
let db_storeAddress = "storeAddress" // 표준 구 주소
let db_title = "title"
let db_nickName = "nickName"
let db_email = "email"
let db_profileImageUrl = "profileImageUrl"
let db_user_profile = "profile"
let db_user_users = "users"
let db_storeName = "storeName"
let db_content = "content"
let db_rating = "rating"
let db_imageURL = "imageURL"
let db_isActive = "isActive"
let db_createdAt = "createdAt"
let db_updatedAt = "updatedAt"
