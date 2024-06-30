//
//  GreetingViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/30/24.
//

import UIKit
import SnapKit
import FirebaseAuth
import Combine

final class GreetingViewController: UIViewController {
    
    
    private lazy var greetingHeaderView = GreetingHeaderView()
    private lazy var greetingBodyView: GreetingBodyView = {
        let view = GreetingBodyView()
        view.appleTapped = appleTapped
        view.googleTapped = googleTapped
        view.guestTapped = guestTapped
        return view
    }()
    
    private lazy var greetingBottomView: GreetingBottomView = {
        let view = GreetingBottomView()
        view.hiddenTapped = hiddenTapped
        return view
    }()
    
    private lazy var vStackview: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            UIView(),
            greetingHeaderView,
            greetingBodyView,
            greetingBottomView
        ])
        stackView.axis = .vertical
        return stackView
    }()
    
    private var appleTapped: (() -> Void)!
    private var googleTapped: (() -> Void)!
    private var hiddenTapped: (() -> Void)!
    private var guestTapped: (() -> Void)!
    private var isAgree = false
    
    
    var viewModel: SignViewModel!
    var userManager = UserManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    convenience init(appleTapped: @escaping () -> Void, googleTapped: @escaping () -> Void, hiddenTapped: @escaping () -> Void, guestTapped: @escaping () -> Void, viewModel: SignViewModel) {
        self.init()
        self.appleTapped = appleTapped
        self.googleTapped = googleTapped
        self.hiddenTapped = hiddenTapped
        self.guestTapped = guestTapped
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        
        bind()
    }
    
    
    private func validateUserData(completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        userManager.fetchUserData(uid: uid) { [self] error, snapshot in
            if let error = error {
                print(error)
            }
            guard let dictionary = snapshot?.value as? [String: Any] else { return }
            isAgree = (dictionary[db_isAgree] as? Bool)!
            
            if isAgree {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func bind() {
        viewModel.loginPublisher.sink { [weak self] result in
            switch result {
            case .success():
                let scene = UIApplication.shared.connectedScenes.first
                if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    self?.validateUserData { result in
                        switch result {
                        case true :
                            sd.switchToMainTabBarController()
                        case false :
                            sd.showVerifyVC()
                        }
                    }
                }
            case .failure(let error):
                self?.showMessage(title: "에러 발생", message: "\(error.localizedDescription)발생했습니다.")
            }
        }.store(in: &cancellables)
    }
    
    private func setupLayout() {
        view.addSubview(vStackview)
        
        vStackview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        greetingHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(150)
            make.leading.trailing.equalToSuperview()
        }
        
        greetingBodyView.snp.makeConstraints { make in
            make.top.equalTo(greetingHeaderView.snp.bottom).offset(80)
            make.leading.trailing.equalToSuperview()
        }
        
        greetingBottomView.snp.makeConstraints { make in
            make.top.equalTo(greetingBodyView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
    }
    
   
}

// MARK: - setting keys

extension GreetingViewController {
    
    func generate(completion: @escaping (Bool) -> Void) {
        let key = Secret().key
        let alert = UIAlertController(title: "관리자 전용", message: "관리자 인증용 Key를 입력하세요.", preferredStyle: .alert)
     
        alert.addTextField { textField in
            textField.placeholder = "Key"
            textField.isSecureTextEntry = true
        }

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            let text = alert.textFields?.first?.text
            
            if text == key {
                completion(true)
            } else {
                completion(false)
            }
        }
        alert.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
}
