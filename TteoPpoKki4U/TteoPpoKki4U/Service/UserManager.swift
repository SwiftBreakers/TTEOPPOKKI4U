//
//  UserManager.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/7/24.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore

class UserManager {
    
    let ref = Database.database().reference()
    
    func updateProfile(uid: String, nickName: String, profile: UIImage, completion: @escaping (Error) -> Void) {
        
        
        let storageRef = Storage.storage().reference(forURL: "gs://tteoppokki4u.appspot.com")
        let storageProfileRef = storageRef.child("profile").child(uid)
        guard let imageData = profile.jpegData(compressionQuality: 0.8) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageProfileRef.putData(imageData, metadata: metaData) { (metadata, error) in
            if let error = error {
                completion(error)
                return
            }
            
            storageProfileRef.downloadURL { (url, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let downloadURL = url else { return }
                let values = ["nickName": nickName, "profileImageUrl": downloadURL.absoluteString]
                self.ref.child("users").child(uid).updateChildValues(values) { error, reference in
                    if let error = error {
                        completion(error)
                        return
                    }
                }
            }
        }
        
    }
    
    func fetchUserData(uid: String, completion: @escaping((Error)?, DataSnapshot?) -> Void) {
        ref.child("users").child(uid).getData(completion: completion)
    }
    
    func writeReview(userDict: [String: Any], completion: (((Error)?) -> Void)?) {
        reviewCollection.addDocument(data: userDict, completion: completion)
    }
    
    func getMyReview(uid: String, completion: @escaping(QuerySnapshot?, (Error)?) -> Void) {
        reviewCollection.whereField("uid", isEqualTo: uid).order(by: "createdAt").getDocuments(completion: completion)
    }
    
    func getSpecificReview(uid: String, storeAddress: String, title: String, completion: @escaping(QuerySnapshot?, (Error)?) -> Void) {
        reviewCollection.whereField("uid", isEqualTo: uid).whereField("storeAddress", isEqualTo: storeAddress).whereField("title", isEqualTo: title).getDocuments(completion: completion)
    }
    
}
