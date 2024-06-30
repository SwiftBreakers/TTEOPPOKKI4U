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
import GoogleSignIn
import SwiftJWT
import Alamofire

class SignManager {
    
    // MARK: - SignIn
    
    func saveApple(appleCredential: ASAuthorizationAppleIDCredential, nonce: String, completion: @escaping (Result<AuthDataResult?, Error>) -> Void) {
        guard let appleToken = appleCredential.identityToken,
              let tokenString = String(data: appleToken, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        
        // 전달된 nonce를 사용하여 자격 증명 생성
        let credential = OAuthProvider.appleCredential(withIDToken: tokenString, rawNonce: nonce, fullName: nil)
        
        print("Created User Apple Credential: \(credential)")
        
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                // authorizationCode를 사용하여 refreshToken을 가져와서 저장
                if let code = appleCredential.authorizationCode, let codeString = String(data: code, encoding: .utf8) {
                    self.getAppleRefreshToken(code: codeString) { refreshToken in
                        guard let refreshToken = refreshToken else {
                            print("Failed to fetch Apple refresh token")
                            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch Apple refresh token"])))
                            return
                        }
                        //print("Successfully fetched Apple refresh token: \(refreshToken)")
                        UserDefaults.standard.set(refreshToken, forKey: "appleRefreshToken")
                        // 저장된 refreshToken 확인
                        if let storedToken = UserDefaults.standard.string(forKey: "appleRefreshToken") {
                            //print("Stored Refresh Token: \(storedToken)")
                        } else {
                            print("Failed to store refresh token")
                        }
                        completion(.success(result))
                    }
                } else {
                    completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch authorization code"])))
                }
            }
        }
    }
    
    func getAppleRefreshToken(code: String, completionHandler: @escaping (String?) -> Void) {
        // JWT 토큰 생성
        let clientSecret = self.makeJWT()
        guard let url = URL(string: "https://appleid.apple.com/auth/token") else {
            print("Failed to create URL")
            completionHandler(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyParameters = [
            "client_id": "com.TeamSwiftbreakers.TteoPpoKki4U", // 여기에는 실제 번들 ID를 넣어야 합니다.
            "client_secret": clientSecret,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.httpBody = bodyParameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to make request: \(error?.localizedDescription ?? "No error description")")
                completionHandler(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(AppleTokenResponse.self, from: data)
                completionHandler(response.refresh_token)
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
                completionHandler(nil)
            }
        }
        
        task.resume()
    }
    
    func googleSignIn(result: GIDSignInResult, completion: @escaping (Result<AuthDataResult?, Error>) -> Void) {
        let idToken = result.user.idToken?.tokenString ?? ""
        let accessToken = result.user.accessToken.tokenString
        
        if idToken.isEmpty {
            completion(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch Google tokens"])))
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Google ID Token과 Access Token 저장
                UserDefaults.standard.set(idToken, forKey: "googleIDToken")
                UserDefaults.standard.set(accessToken, forKey: "googleAccessToken")
                completion(.success(result))
            }
        }
    }
    
    func saveUserData(user: UserModel) {
        let ref = Database.database().reference()
        let userData: [String: Any] = [
            db_uid: user.uid,
            db_nickName: user.nickName,
            db_email: user.email,
            db_profileImageUrl: user.profileImageUrl,
            db_isBlock: user.isBlock,
            db_isAgree: user.isAgree
        ]
        ref.child("users").child(user.uid).setValue(userData)
    }
    
    func fetchUserData(uid: String, completion: @escaping (Error?, DataSnapshot?) -> Void) {
        let ref = Database.database().reference()
        ref.child("users").child(uid).getData(completion: completion)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func randomNonceString(length: Int = 32) -> String {
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
    
    // client_secret 생성
    func makeJWT() -> String {
        let myHeader = Header(kid: "RS7QZ647UQ") // Apple Key ID
        
        struct MyClaims: Claims {
            let iss: String
            let iat: Int
            let exp: Int
            let aud: String
            let sub: String
        }
        
        let nowDate = Date()
        let iat = Int(nowDate.timeIntervalSince1970)
        let exp = iat + 3600 // 1 hour expiration
        
        let myClaims = MyClaims(
            iss: "LA95MXQ3R5", // Apple Team ID
            iat: iat,
            exp: exp,
            aud: "https://appleid.apple.com",
            sub: "com.TeamSwiftbreakers.TteoPpoKki4U" // App Bundle ID
        )
        
        var myJWT = JWT(header: myHeader, claims: myClaims)
        
        // Load the private key from .p8 file
        guard let url = Bundle.main.url(forResource: "AuthKey_RS7QZ647UQ", withExtension: "p8") else {
            print("Failed to find the .p8 file.")
            return ""
        }
        
        do {
            let privateKey = try Data(contentsOf: url)
            let jwtSigner = JWTSigner.es256(privateKey: privateKey)
            let signedJWT = try myJWT.sign(using: jwtSigner)
            
            //print("🗝 signedJWT - \(signedJWT)")
            return signedJWT
        } catch {
            print("Failed to sign JWT: \(error)")
            return ""
        }
    }
    
    // MARK: - SignOut
    
    private func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let signOutError {
            completion(.failure(signOutError))
        }
    }
    
    // Google 로그아웃
    func signOutGoogle(completion: @escaping (Error?) -> Void) {
        GIDSignIn.sharedInstance.signOut()
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
                UserDefaults.standard.removeObject(forKey: "appleAuthorizedUserIdKey")
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
                            // Revoke the Apple token
                            guard let refreshToken = UserDefaults.standard.string(forKey: "appleRefreshToken") else {
                                completion(.failure(NSError(domain: "AppleSignOut", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get refresh token"])))
                                return
                            }
                            print("Using Refresh Token: \(refreshToken)") // 추가 디버깅 로그
                            let clientSecret = self.makeJWT()
                            self.revokeAppleToken(clientSecret: clientSecret, token: refreshToken) {
                                self.signOut(completion: completion)
                            }
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
    
    
    func revokeAppleToken(clientSecret: String, token: String, completionHandler: @escaping () -> Void) {
        let url = "https://appleid.apple.com/auth/revoke?client_id=com.TeamSwiftbreakers.TteoPpoKki4U&client_secret=\(clientSecret)&token=\(token)&token_type_hint=refresh_token"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        
        AF.request(url,
                   method: .post,
                   headers: header)
        .validate(statusCode: 200..<600)
        .responseData { response in
            guard let statusCode = response.response?.statusCode else { return }
            if statusCode == 200 {
                print("애플 토큰 삭제 성공!")
                completionHandler()
            } else {
                print("애플 토큰 삭제 실패, 상태 코드: \(statusCode)")
            }
        }
    }
    
    
    func deleteCurrentUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."])
            completion(.failure(error))
            return
        }
        
        for provider in user.providerData {
            switch provider.providerID {
            case "apple.com":
                signOutApple { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Revoke the Apple token
                        guard let refreshToken = UserDefaults.standard.string(forKey: "appleRefreshToken") else {
                            completion(.failure(NSError(domain: "AppleSignOut", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get refresh token"])))
                            return
                        }
                        print("Using Refresh Token: \(refreshToken)") // 추가 디버깅 로그
                        let clientSecret = self.makeJWT()
                        self.revokeAppleToken(clientSecret: clientSecret, token: refreshToken) {
                            self.deleteUserFromDatabase(uid: user.uid, completion: completion)
                        }
                    }
                }
            case "google.com":
                var credential: AuthCredential?
                if let idToken = UserDefaults.standard.string(forKey: "googleIDToken"),
                   let accessToken = UserDefaults.standard.string(forKey: "googleAccessToken") {
                    credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                    print("Delete User Google Credential: \(credential)")
                }
                
                guard let authCredential = credential else {
                    let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "재인증을 위한 자격 증명을 가져올 수 없습니다."])
                    completion(.failure(error))
                    return
                }
                print("Delete User Google Credential: \(authCredential)")
                
                // 사용자 재인증
                user.reauthenticate(with: authCredential) { _, error in
                    if let error = error {
                        print("Reauthentication failed: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        // 재인증 후 사용자 삭제 수행
                        self.performDelete(user: user, completion: completion)
                    }
                }
            default:
                break
            }
        }
    }
    
    func performDelete(user: FirebaseAuth.User, completion: @escaping (Result<Void, Error>) -> Void) {
        for provider in user.providerData {
            switch provider.providerID {
            case "apple.com":
                signOutApple { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        guard let refreshToken = UserDefaults.standard.string(forKey: "appleRefreshToken") else {
                            completion(.failure(NSError(domain: "AppleSignOut", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get refresh token"])))
                            return
                        }
                        let clientSecret = self.makeJWT()
                        self.revokeAppleToken(clientSecret: clientSecret, token: refreshToken) {
                            self.deleteUserFromDatabase(uid: user.uid, completion: completion)
                        }
                    }
                }
            case "google.com":
                signOutGoogle { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.deleteUserFromDatabase(uid: user.uid, completion: completion)
                    }
                }
            default:
                break
            }
        }
    }
    
    private func deleteUserFromDatabase(uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = Database.database().reference()
        ref.child("users").child(uid).removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                if let user = Auth.auth().currentUser {
                    user.delete { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            UserDefaults.standard.removeObject(forKey: "appleRefreshToken") // 회원 탈퇴 시 refresh token 삭제
                            completion(.success(()))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."])))
                }
            }
        }
    }
    
    
    
}
