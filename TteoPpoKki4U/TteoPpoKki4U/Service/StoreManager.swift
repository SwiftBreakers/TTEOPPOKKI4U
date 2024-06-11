//
//  StoreManager.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/9/24.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore

class StoreManager {
    
    func reqeustStore(storeAddress: String, completion: @escaping(QuerySnapshot?, (Error)?) -> Void) {
        reviewCollection.whereField(db_storeAddress, isEqualTo: storeAddress).getDocuments(completion: completion)
    }
    
    func requestScrap(uid: String, completion: @escaping(QuerySnapshot?, (any Error)?) -> Void) {
        scrappedCollection.whereField(db_uid, isEqualTo: uid).getDocuments(completion: completion)
    }

}
