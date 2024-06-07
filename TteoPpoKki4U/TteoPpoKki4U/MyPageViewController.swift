//
//  MyPageViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import SnapKit
import Combine
import FirebaseAuth
import Kingfisher

class MyPageViewController: UIViewController {
    
    let myPageView = MyPageView()
    let myPageVM = MyPageViewModel()
    let userManager = UserManager()
    
    private var signVM: SignViewModel!
    private var signOutTapped: (() -> Void)!
    
    private var cancellables = Set<AnyCancellable>()
    
    
    convenience init(signOutTapped: @escaping () -> Void, viewModel: SignViewModel) {
        self.init()
        self.signOutTapped = signOutTapped
        self.signVM = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        view.addSubview(myPageView)
        
        myPageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(16)
            make.leading.trailing.bottom.equalTo(view)
        }
        
        myPageView.collectionView.dataSource = self
        myPageView.collectionView.delegate = self
        bind()
        fetchUser()
    }
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        userManager.fetchUserData(uid: uid) { [self] error, snapshot in
            if let error = error {
                print(error)
            }
            
            guard let dictionary = snapshot?.value as? [String: Any] else { return }
           
            myPageView.userProfile.kf.setImage(with: URL(string: dictionary["profileImageUrl"] as! String))
          
            
        }
    }
    
    private func bind() {
        signVM.logoutPublisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                return
            case .failure(let error):
                let alert = UIAlertController(title: "에러 발생", message: "\(error.localizedDescription)이 발생했습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
        } receiveValue: { _ in
            print("logout")
        }.store(in: &cancellables)
    }
}

extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return myPageVM.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPageVM.sections[section].options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPageCollectionViewCell.identifier, for: indexPath) as! MyPageCollectionViewCell
        let option = myPageVM.sections[indexPath.section].options[indexPath.item]
        cell.configure(with: option)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch indexPath {
        case [0, 0]:
            let personalInfoVC = PersonalInfoViewController()
            present(personalInfoVC, animated: true)
        case [1, 0]:
            let MyScrapVC = MyScrapViewController()
            MyScrapVC.modalPresentationStyle = .fullScreen
            present(MyScrapVC, animated: true)
        case [1, 1]:
            let MyReviewVC = MyReviewViewController()
            MyReviewVC.modalPresentationStyle = .fullScreen
            present(MyReviewVC, animated: true)
        case [1, 2]:
            print("3")
        case [2, 0]:
            print("하위 페이지에서 회원탈퇴 버튼 생성 예정")
        case [2, 1]:
            signOutTapped!()
        case [2, 2]:
            let chatVC = ChatCollectionViewController()
            present(chatVC, animated: true)
        default:
            return
        }
    }
}


