//
//  SignUpVM.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/31/24.
//

import Foundation

class SignVM {
    
    let signManager = SignManager()
    
    func signUp(nickName: String, email: String, password: String, onError: @escaping((Error) -> Void)) {
        signManager.signUp(nickName: nickName, email: email, password: password) { error in
            onError(error)
        }
    }
    
    func signIn(email: String, password: String, onError: @escaping((Error) -> Void)) {
        signManager.signIn(email: email, password: password) { error in
            onError(error)
        }
    }
}
