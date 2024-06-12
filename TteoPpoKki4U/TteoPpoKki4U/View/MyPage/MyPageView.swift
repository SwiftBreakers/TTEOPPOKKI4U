//
//  MyPageView.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/29/24.
//

import UIKit

class MyPageView: UIView {
    
    let userProfile: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "defaultImage")
//        view.backgroundColor = ThemeColor.mainGreen
        view.layer.cornerRadius = 60
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        return view
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 20)
        label.text = "떡볶이왕"
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
        [userProfile, userNameLabel, collectionView].forEach { view in
            self.addSubview(view)
        }
        
        userProfile.snp.makeConstraints { make in
            make.height.width.equalTo(120)
            make.top.equalToSuperview().offset(128)
            make.leading.equalToSuperview().offset(40)
//            make.trailing.equalToSuperview().inset(180)
 //           make.bottom.equalTo(collectionView.snp.top).offset(-40)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userProfile)
            make.leading.equalTo(userProfile.snp.trailing).offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
  
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(userProfile.snp.bottom).offset(40)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    
}
