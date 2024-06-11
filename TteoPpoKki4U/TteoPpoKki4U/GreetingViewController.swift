//
//  GreetingViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/30/24.
//

import UIKit
import SnapKit
import Combine

final class GreetingViewController: UIViewController {

    
    private lazy var greetingHeaderView = GreetingHeaderView()
    private lazy var greetingBodyView: GreetingBodyView = {
        let view = GreetingBodyView()
        view.appleTapped = appleTapped
        view.kakaoTapped = kakaoTapped
        view.googleTapped = googleTapped
        return view
    }()

    lazy var vStackview: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            UIView(),
            greetingHeaderView,
            greetingBodyView
        ])
        stackView.axis = .vertical
        return stackView
    }()
    
    private var appleTapped: (() -> Void)!
    private var kakaoTapped: (() -> Void)!
    private var googleTapped: (() -> Void)!
    
    var viewModel: SignViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    convenience init(appleTapped: @escaping () -> Void, kakaoTapped: @escaping () -> Void, googleTapped: @escaping () -> Void, viewModel: SignViewModel) {
        self.init()
        self.appleTapped = appleTapped
        self.kakaoTapped = kakaoTapped
        self.googleTapped = googleTapped
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        
        bind()
    }
    
    private func bind() {
        viewModel.loginPublisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                return
            case .failure(let error):
                self?.showMessage(title: "에러 발생", message: "\(error.localizedDescription)이 발생했습니다.")
            }
        } receiveValue: { _ in
            let scene = UIApplication.shared.connectedScenes.first
            if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sd.switchToMainTabBarController()
            }
        }.store(in: &cancellables)
    }
    
    private func setupLayout() {
        view.addSubview(vStackview)
        
        vStackview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        greetingHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        greetingBodyView.snp.makeConstraints { make in
            make.top.equalTo(greetingHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    

}
