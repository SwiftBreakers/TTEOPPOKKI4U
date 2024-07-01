//
//  MyPageView.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/29/24.
//

import UIKit
import SnapKit
import FirebaseAuth

class MyPageView: UIView {
    
    let userProfile: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "personIcon")
        view.layer.cornerRadius = 60
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        view.layer.borderWidth = 0.3
        return view
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .gray
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(nil, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 20)
        label.text = "로그인이 필요합니다."
        label.textColor = ThemeColor.mainBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let userRankLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 16)
        label.text = ""
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 50)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(MyPageCollectionViewCell.self, forCellWithReuseIdentifier: MyPageCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    var editTapped: (() -> Void)?
    
    //빌트인1
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layout()
    }
    
    //빌트인2
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        [userProfile, editButton, userNameLabel, userRankLabel, collectionView].forEach { view in
            self.addSubview(view)
        }
        
        userProfile.snp.makeConstraints { make in
            make.height.width.equalTo(120)
            make.top.equalToSuperview().offset(90)
            make.centerX.equalToSuperview()
        }
        
        editButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.trailing.bottom.equalTo(userProfile).offset(-8)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userProfile.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        userRankLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
  
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(userRankLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func editButtonTapped() {
        editTapped?()
    }
}

