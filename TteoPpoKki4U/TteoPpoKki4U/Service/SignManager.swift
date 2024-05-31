//
//  SignManager.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/31/24.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignManager {
    
    func signUp(nickName: String, email: String, password: String, onError: @escaping((Error) -> Void)) {
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            
            // error를 escaping closure를 통해 전달.
            if error != nil {
                onError(error!)
                return
            }
            
            // error가 없을 경우
            if let authData = authDataResult {
                var dict: Dictionary<String, Any> = [
                    "uid": authData.user.uid,
                    "email": authData.user.email,
                    "username": nickName,
                    "profileImageUrl": ""
                ]
                
                // Database에 저장.
                Database.database().reference().child("users").child(authData.user.uid).updateChildValues(dict) { error, ref in
                    if error != nil {
                        onError(error!)
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String, onError: @escaping((Error) -> Void)) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            // error를 escaping closure를 통해 전달.
            if error != nil {
                onError(error!)
                return
            }
            
            print(authDataResult?.user.email)
        }
    }
}


