//
//  UserManager.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/7/24.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

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
                self.ref.child("users").child(uid).setValue(["nickName": nickName, "profileImageUrl": downloadURL.absoluteString])
            }
        }
 
    }
    
    func fetchUserData(uid: String, completion: @escaping((Error)?, DataSnapshot?) -> Void) {
        ref.child("users").child(uid).getData(completion: completion)
    }
}
