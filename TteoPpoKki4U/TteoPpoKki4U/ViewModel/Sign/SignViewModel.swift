//
//  SignUpVM.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/31/24.
//

import Foundation
import AuthenticationServices
import GoogleSignIn
import FirebaseAuth
import Combine
import Alamofire
import SwiftJWT

class SignViewModel: NSObject {
    
    private let signManager: SignManager
    
    init(signManager: SignManager) {
        self.signManager = signManager
    }
    
    var loginPublisher = PassthroughSubject<Result<Void, Error>, Never>()
    var logoutPublisher = PassthroughSubject<Result<Void, Error>, Never>()
    
    private var currentNonce: String?
    private var reauthenticationCompletion: ((Result<AuthCredential, Error>) -> Void)?
    
    func appleLoginDidTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        let nonce = signManager.randomNonceString()
        currentNonce = nonce
        UserDefaults.standard.set(nonce, forKey: "appleRawNonce") // nonce 저장
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = signManager.sha256(nonce) // SHA-256 해시 적용
        
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
            
            self?.signManager.googleSignIn(result: result) { result in
                switch result {
                case .success(let authResult):
                    guard let user = authResult?.user else { return }
                    
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
                case .failure(let error):
                    self?.loginPublisher.send(.failure(error))
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
    
    // client_refreshToken
    func getAppleRefreshToken(code: String, completionHandler: @escaping (String?) -> Void) {
        
        guard let secret = UserDefaults.standard.string(forKey: "AppleClientSecret") else {return}
        
        let url = "https://appleid.apple.com/auth/token?client_id=YOUR_BUNDLE_ID&client_secret=\(secret)&code=\(code)&grant_type=authorization_code"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        
        //print("🗝 clientSecret - \(UserDefaults.standard.string(forKey: "AppleClientSecret") ?? "")")
        // print("🗝 authCode - \(code)")
        
        let _ = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<500)
            .responseData { response in
                // print("🗝 response - \(response.description)")
                
                switch response.result {
                case .success(let output):
                    //                print("🗝 ouput - \(output)")
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(AppleTokenResponse.self, from: output){
                        //                    print("🗝 output2 - \(decodedData.refresh_token)")
                        
                        if decodedData.refresh_token == nil{
                            self.loginPublisher.send(.success(()))
                        }else{
                            completionHandler(decodedData.refresh_token)
                        }
                    }
                    
                case .failure(_):
                    self.loginPublisher.send(.success(()))
                }
            }
    }
    
    func deleteUserAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인된 사용자가 없습니다."])
            completion(.failure(error))
            return
        }

        for provider in user.providerData {
            switch provider.providerID {
            case "apple.com":
                reauthenticateAppleUser { [weak self] result in
                    switch result {
                    case .success(let credential):
                        user.reauthenticate(with: credential) { _, error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                self?.signManager.performDelete(user: user, completion: completion)
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case "google.com":
                var credential: AuthCredential?
                if let idToken = UserDefaults.standard.string(forKey: "googleIDToken"),
                   let accessToken = UserDefaults.standard.string(forKey: "googleAccessToken") {
                    credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                }

                guard let authCredential = credential else {
                    let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "재인증을 위한 자격 증명을 가져올 수 없습니다."])
                    completion(.failure(error))
                    return
                }

                user.reauthenticate(with: authCredential) { _, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.signManager.performDelete(user: user, completion: completion)
                    }
                }
            default:
                break
            }
        }
    }
    
    func reauthenticateAppleUser(completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        let nonce = signManager.randomNonceString()
        currentNonce = nonce
        UserDefaults.standard.set(nonce, forKey: "appleRawNonce")
        request.nonce = signManager.sha256(nonce)
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        self.reauthenticationCompletion = { result in
            switch result {
            case .success(let credential):
                completion(.success(credential))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        authorizationController.performRequests()
    }
    
}

extension SignViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        reauthenticationCompletion?(.failure(error))
        loginPublisher.send(.failure(error))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            reauthenticationCompletion?(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple credential not found"])))
            return
        }
        
        let userID = credential.user
        if UserDefaults.standard.string(forKey: "appleAuthorizedUserIdKey") == nil {
            UserDefaults.standard.set(userID, forKey: "appleAuthorizedUserIdKey")
        }
        
        let nonce = currentNonce ?? ""
        print("Authorization Nonce: \(nonce)")
        
        guard let idToken = credential.identityToken, let idTokenString = String(data: idToken, encoding: .utf8) else {
            reauthenticationCompletion?(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch ID token"])))
            return
        }
        
        if let reauthCompletion = reauthenticationCompletion {
            let appleCredential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: credential.fullName)
            reauthCompletion(.success(appleCredential))
            self.reauthenticationCompletion = nil
        } else {
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
    
}
