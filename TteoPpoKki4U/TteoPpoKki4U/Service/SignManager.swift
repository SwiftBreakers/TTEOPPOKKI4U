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
            "uid": user.uid,
            "nickName": "",
            "email": user.email,
            "profileImageUrl": ""
        ]
        ref.child("users").child(user.uid).setValue(userData)
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
    
    // Kakao 로그아웃
    func signOutKakao(completion: @escaping (Error?) -> Void) {
        UserApi.shared.logout { error in
            if let error = error {
                print("DEBUG: Kakao 로그아웃 에러 \(error.localizedDescription)")
            } else {
                print("DEBUG: Kakao 로그아웃 성공")
            }
            completion(error)
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
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: "YOUR_USER_ID") { (credentialState, error) in
            switch credentialState {
            case .authorized:
                completion(nil)
            case .revoked:
                completion(nil)
            case .notFound:
                completion(nil)
            default:
                completion(error)
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
                case "kakao.com":
                    signOutKakao { error in
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


