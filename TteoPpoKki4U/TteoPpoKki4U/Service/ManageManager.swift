//
//  ManageManager.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/12/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ManageManager {
    
    let ref = Database.database().reference()
    
    func fetchUsers(completion: @escaping ((any Error)?, DataSnapshot?) -> Void) {
        ref.child(db_user_users).getData(completion: completion)
    }
    
    func editSpecificUser(uid: String, values: [String: Any], completion: @escaping ((any Error)?, DatabaseReference) -> Void) {
        ref.child(db_user_users).child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func getSpecificReview(uid: String, storeAddress: String, title: String, completion: @escaping(QuerySnapshot?, (Error)?) -> Void) {
        reviewCollection.whereField(db_uid, isEqualTo: uid).whereField(db_storeAddress, isEqualTo: storeAddress).whereField(db_title , isEqualTo: title).getDocuments(completion: completion)
    }
    
    func fetchUserReviews(completion: @escaping (QuerySnapshot?, (any Error)?) -> Void) {
        reviewCollection.getDocuments(completion: completion)
    }
    
    func getUserReview(uid: String, completion: @escaping (QuerySnapshot?, (any Error)?) -> Void) {
        reviewCollection.whereField(db_uid, isEqualTo: uid).getDocuments(completion: completion)
    }
    
}
