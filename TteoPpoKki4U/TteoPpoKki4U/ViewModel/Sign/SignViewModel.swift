//
//  SignUpVM.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/31/24.
//

import Foundation
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn
import FirebaseAuth
import Combine

class SignViewModel: NSObject {
    
    private let signManager: SignManager
    
    init(signManager: SignManager) {
        self.signManager = signManager
    }
    
    var loginPublisher = PassthroughSubject<Result<Void, Error>, Never>()
    var logoutPublisher = PassthroughSubject<Result<Void, Error>, Never>()
    
    private var currentNonce: String?
    
    func appleLoginDidTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        let nonce = signManager.randomNonceString()
        
        currentNonce = nonce
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = signManager.sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    func googleLoginDidTapped(presentViewController: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presentViewController) { [weak self] signInResult, error in
            if let error = error {
                self?.loginPublisher.send(.failure(error))
                return
            }
            
            guard let result = signInResult else { return }
            
            let user = result.user
            let idToken = user.idToken?.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    self?.loginPublisher.send(.failure(error))
                    return
                }
                
                guard let user = result?.user else { return }
                
                let uid = user.uid
                let email = user.email
                
                self?.signManager.fetchUserData(uid: uid) { error, snapshot in
                    if let error = error {
                        self?.loginPublisher.send(.failure(error))
                        return
                    }
                    
                    if let snapshot = snapshot {
                        if let userData = snapshot.value as? [String: Any] {
                            let isBlockInt = userData[db_isBlock] as? Int ?? 0
                            let isBlock = isBlockInt != 0
                            if isBlock {
                                let error = NSError(domain: "", code: 403, userInfo: [NSLocalizedDescriptionKey: "현재 계정은 계정차단 관련 문제가 있습니다."])
                                self?.loginPublisher.send(.failure(error))
                                self?.signOut {
                                    // Completion handler for sign out
                                }
                            } else {
                                self?.loginPublisher.send(.success(()))
                            }
                        } else {
                            let model = UserModel(uid: user.uid, email: email!, isBlock: false, nickName: "", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/tteoppokki4u.appspot.com/o/dummyProfile%2FdefaultImage.png?alt=media&token=b4aab21e-e19a-42b7-9d17-d92a3801a327")
                            self?.signManager.saveUserData(user: model)
                            self?.loginPublisher.send(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    func signOut(completion: @escaping () -> Void) {
        signManager.signOutCurrentUser { [weak self] result in
            switch result {
            case .success:
                self?.logoutPublisher.send(.success(()))
                completion()
            case .failure(let error):
                self?.logoutPublisher.send(.failure(error))
                completion()
            }
        }
    }
    
    func checkUserisBlock(uid: String, completion: @escaping (Bool) -> Void) {
        signManager.fetchUserData(uid: uid) { error, dataSnapshot in
            if let dataSnapshot = dataSnapshot, let userData = dataSnapshot.value as? [String: Any] {
                let isBlockInt = userData[db_isBlock] as? Int ?? 0
                completion(isBlockInt != 0)
            } else {
                completion(false)
            }
        }
    }
}

extension SignViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginPublisher.send(.failure(error))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        let userID = credential.user
        
        if UserDefaults.standard.string(forKey: "appleAuthorizedUserIdKey") == nil {
            UserDefaults.standard.set(userID, forKey: "appleAuthorizedUserIdKey")
        }
        
        let nonce = currentNonce ?? ""
        
        signManager.saveApple(appleCredential: credential, nonce: nonce) { [weak self] result in
            switch result {
            case .success(let result):
                if let user = result?.user {
                    let email = credential.email ?? ""
                    self?.signManager.fetchUserData(uid: user.uid) { error, snapshot in
                        if let error = error {
                            self?.loginPublisher.send(.failure(error))
                            return
                        }
                        
                        if let snapshot = snapshot, let userData = snapshot.value as? [String: Any] {
                            let isBlockInt = userData[db_isBlock] as? Int ?? 0
                            let isBlock = isBlockInt != 0
                            if isBlock {
                                let error = NSError(domain: "", code: 403, userInfo: [NSLocalizedDescriptionKey: "현재 계정은 계정차단 관련 문제가 있습니다."])
                                self?.loginPublisher.send(.failure(error))
                                self?.signOut {
                                    // Completion handler for sign out
                                }
                            } else {
                                self?.loginPublisher.send(.success(()))
                            }
                        } else {
                            let model = UserModel(uid: user.uid, email: email, isBlock: false, nickName: "", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/tteoppokki4u.appspot.com/o/dummyProfile%2FdefaultImage.png?alt=media&token=b4aab21e-e19a-42b7-9d17-d92a3801a327")
                            self?.signManager.saveUserData(user: model)
                            self?.loginPublisher.send(.success(()))
                        }
                    }
                }
            case .failure(let error):
                self?.loginPublisher.send(.failure(error))
            }
        }
    }
}