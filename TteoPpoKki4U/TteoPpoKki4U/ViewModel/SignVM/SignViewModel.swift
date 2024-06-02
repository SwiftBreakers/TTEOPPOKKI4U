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
import Combine

protocol LoginInput {
    func appleLoginDidTapped ()
    func kakaoLoginDidTapped ()
    func googleLoginDidTapped (presentViewController: UIViewController)
}

protocol LoginOutput {
    var loginPublisher: PassthroughSubject<Void, Error> { get set }
}

protocol LoginViewModelIO: LoginInput, LoginOutput {
    
}

class SignViewModel: NSObject, LoginViewModelIO {
    
    
    private let signManager: SignManager
    
    init(signManager: SignManager) {
        self.signManager = signManager
    }
    
    
    var loginPublisher = PassthroughSubject<Void, any Error>()
    
    func appleLoginDidTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    func kakaoLoginDidTapped() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {[weak self] (oauthToken, error) in
                if let error = error {
                    self?.loginPublisher.send(completion: .failure(error))
                } else {
                    self?.loginPublisher.send()
                    print("loginWithKakaoTalk() success.")
                    //do something
                    _ = oauthToken
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {[weak self] (oauthToken, error) in
                if let error = error {
                    self?.loginPublisher.send(completion: .failure(error))
                } else {
                    self?.loginPublisher.send()
                    print("loginWithKakaoTalk() success.")
                    //do something
                    _ = oauthToken
                }
            }
        }
    }
    
    func googleLoginDidTapped(presentViewController: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presentViewController) { [weak self] signInResult, error in
            if let error = error {
                self?.loginPublisher.send(completion: .failure(error))
            }
            
            guard let result = signInResult else { return }
            self?.loginPublisher.send()
            print(result.user.userID)
            print(result)
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
        print(credential.email)
        print(credential.user)
        loginPublisher.send()
        
    }
    
}
