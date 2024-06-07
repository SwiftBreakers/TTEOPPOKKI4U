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
import Firebase
import Combine

class SignViewModel: NSObject {
    
    private let signManager: SignManager
    
    
    init(signManager: SignManager) {
        self.signManager = signManager
    }
    
    
    var loginPublisher = PassthroughSubject<Void, Error>()
    var logoutPublisher = PassthroughSubject<Void, Error>()
    
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
    
    
    func kakaoLoginDidTapped() {
        if AuthApi.hasToken() {
            UserApi.shared.accessTokenInfo { [weak self] _, error in
                if let error = error {
                    print("Token info error: \(error.localizedDescription)")
                    self?.openKakaoService()
                } else {
                    print("Token is valid")
                    self?.loadingInfoDidKakaoAuth()
                }
            }
        } else {
            print("No token, opening Kakao service")
            openKakaoService()
        }
    }
    
    private func openKakaoService() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                if let error = error {
                    self?.loginPublisher.send(completion: .failure(error))
                    return
                }
                print("KakaoTalk login successful")
                _ = oauthToken
                self?.loadingInfoDidKakaoAuth()
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                if let error = error {
                    self?.loginPublisher.send(completion: .failure(error))
                    return
                }
                print("KakaoAccount login successful")
                _ = oauthToken
                self?.loadingInfoDidKakaoAuth()
            }
        }
    }
    
    private func loadingInfoDidKakaoAuth() {
        UserApi.shared.me { [weak self] kakaoUser, error in
            if let error = error {
                self?.loginPublisher.send(completion: .failure(error))
                return
            }
            guard let uid = kakaoUser?.id else {
                return
            }
            let email = kakaoUser?.kakaoAccount?.email ?? "\(uid)@kakao.com"
            
            
            let userModel = UserModel(uid: String(uid), email: email, isBlock: false, nickName: "", profileImageUrl: "")
            self?.signInToFirebase(with: userModel)
        }
    }
    
    private func signInToFirebase(with userModel: UserModel) {
            let emailForSignIn = userModel.email
            let passwordForSignIn = userModel.uid
            
            let credential = OAuthProvider.credential(withProviderID: "oidc.kakao.com", accessToken: passwordForSignIn)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    self?.loginPublisher.send(completion: .failure(error))
                    return
                }
                
                print("Firebase sign in successful")
                self?.signManager.saveUserData(user: userModel)
                self?.loginPublisher.send(())
            }
        }

    
    private func signUpToFirebase(with userModel: UserModel) {
        let emailForSignUp = userModel.email
        let passwordForSignUp = userModel.uid
        
        Auth.auth().createUser(withEmail: emailForSignUp, password: passwordForSignUp) { [weak self] authResult, error in
            if let error = error {
                self?.loginPublisher.send(completion: .failure(error))
                return
            }
            
            print("Firebase sign up successful")
            self?.signManager.saveUserData(user: userModel)
            self?.loginPublisher.send(())
        }
    }
    
    
    
    func googleLoginDidTapped(presentViewController: UIViewController) {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentViewController) { [weak self] signInResult, error in
            if let error = error {
                self?.loginPublisher.send(completion: .failure(error))
            }
            
            
            guard let result = signInResult else { return }
            
            let user = result.user
            let idToken = user.idToken?.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    self?.loginPublisher.send(completion: .failure(error))
                }
                
                guard let user = result?.user else { return }
                
                let uid = user.uid
                let email = user.email
                
                let model = UserModel(uid: uid, email: email!, isBlock: false, nickName: "", profileImageUrl: "")
                
                self?.signManager.saveUserData(user: model)
                
            }
            
            self?.loginPublisher.send()
        }
    }
    
    func signOut() {
        signManager.signOutCurrentUser { [weak self] result in
            switch result {
            case .success:
                self?.logoutPublisher.send()
            case .failure(let error):
                self?.logoutPublisher.send(completion: .failure(error))
            }
        }
    }
    
}



extension SignViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        
        
        return UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        loginPublisher.send(completion: .failure(error))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        let nonce = currentNonce
        
        signManager.saveApple(appleCredential: credential, nonce: nonce!) { [weak self] result in
            switch result {
            case .success(let result):
                if let user = result?.user {
                    let email = credential.email ?? ""
                    let userModel = UserModel(uid: user.uid, email: email, isBlock: false, nickName: "", profileImageUrl: "")
                    self?.signManager.saveUserData(user: userModel)
                }
            case .failure(let error):
                self?.loginPublisher.send(completion: .failure(error))
            }
        }
        
        loginPublisher.send()
        
    }
    
}
