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
import AuthenticationServices
import CryptoKit
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn

class SignManager {
    
    // MARK: - SignIn
    
    func saveApple(appleCredential: ASAuthorizationAppleIDCredential, nonce: String, completion: @escaping (Result<AuthDataResult?, Error>) -> Void) {
        
        let appleToken = String(data: appleCredential.identityToken!, encoding: .utf8)!
        
        let credential = OAuthProvider.appleCredential(withIDToken: appleToken,
                                                       rawNonce: nonce,
                                                       fullName: appleCredential.fullName)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            }
            completion(.success(result))
        }
    }
    
    func saveUserData(user: UserModel) {
        let ref = Database.database().reference()
        let userData: [String: Any] = [
            db_uid: user.uid,
            db_nickName: "",
            db_email: user.email,
            db_profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/tteoppokki4u.appspot.com/o/dummyProfile%2FdefaultImage.png?alt=media&token=b4aab21e-e19a-42b7-9d17-d92a3801a327",
            db_isBlock: user.isBlock
        ]
        ref.child("users").child(user.uid).setValue(userData)
    }
    
    func fetchUserData(uid: String, completion: @escaping ((any Error)?, DataSnapshot?) -> Void) {
        let ref = Database.database().reference()
        ref.child("users").child(uid).getData(completion: completion)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // MARK: - SignOut
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion(.success(()))
        } catch let signOutError {
            completion(.failure(signOutError))
        }
    }
    
    // Google 로그아웃
    func signOutGoogle(completion: @escaping (Error?) -> Void) {
        GIDSignIn.sharedInstance.signOut()
        print("DEBUG: Google 로그아웃 성공")
        completion(nil)
    }
    
    // Apple 로그아웃 함수
    func signOutApple(completion: @escaping (Error?) -> Void) {
        guard let userID = UserDefaults.standard.string(forKey: "appleAuthorizedUserIdKey") else {
            let error = NSError(domain: "AppleSignOut", code: -1, userInfo: [NSLocalizedDescriptionKey: "No Apple ID user ID found."])
            completion(error)
            return
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
            if let error = error {
                completion(error)
                return
            }
            
            switch credentialState {
            case .authorized:
                completion(nil)
            case .revoked, .notFound:
                // Consider the user logged out if the credential is revoked or not found
                completion(nil)
            default:
                let unknownError = NSError(domain: "AppleSignOut", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown Apple credential state."])
                completion(unknownError)
            }
        }
    }
    
    // 로그인된 서비스 확인 및 로그아웃
    func signOutCurrentUser(completion: @escaping (Result<Void, Error>) -> Void) {
            if let user = Auth.auth().currentUser {
                for provider in user.providerData {
                    switch provider.providerID {
                    case "apple.com":
                        signOutApple { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                self.signOut(completion: completion)
                            }
                        }
                    case "google.com":
                        signOutGoogle { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                self.signOut(completion: completion)
                            }
                        }
                    default:
                        break
                    }
                }
            } else {
                let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."])
                completion(.failure(error))
            }
        }

}


