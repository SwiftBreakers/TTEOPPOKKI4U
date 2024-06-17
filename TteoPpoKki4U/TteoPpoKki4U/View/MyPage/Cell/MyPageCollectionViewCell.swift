//
//  MyPageCollectionViewCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/29/24.
//

import UIKit

class MyPageCollectionViewCell: UICollectionViewCell {
    
        static let identifier = "MyPageCollectionViewCell"
        
        private let iconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = ThemeColor.mainOrange
            return imageView
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = ThemeFont.fontRegular()
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let arrowImageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
            imageView.tintColor = .gray
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 8
            contentView.layer.masksToBounds = true
            
            contentView.addSubview(iconImageView)
            contentView.addSubview(titleLabel)
            contentView.addSubview(arrowImageView)
            
            iconImageView.snp.makeConstraints { make in
                       make.centerY.equalTo(contentView)
                       make.leading.equalTo(contentView).offset(16)
                       make.width.height.equalTo(30)
                   }
                   
                   titleLabel.snp.makeConstraints { make in
                       make.centerY.equalTo(contentView)
                       make.leading.equalTo(iconImageView.snp.trailing).offset(16)
                   }
                   
                   arrowImageView.snp.makeConstraints { make in
                       make.centerY.equalTo(contentView)
                       make.trailing.equalTo(contentView).offset(-16)
                       make.width.equalTo(16)
                       make.height.equalTo(22)
                   }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configure(with model: MyPageModel) {
            iconImageView.image = UIImage(systemName: model.icon)
            titleLabel.text = model.title
        }
}
