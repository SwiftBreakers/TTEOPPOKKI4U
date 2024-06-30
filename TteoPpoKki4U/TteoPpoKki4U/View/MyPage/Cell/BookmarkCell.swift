//
//  BookmarkCollectionViewCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/14/24.
//

import UIKit
import Kingfisher

class BookmarkCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let bookmarkIcon = UIImageView()
    var bookmarkIconTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bookmarkIcon.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(deselect))
        bookmarkIcon.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // UI 설정 함수
    private func setupUI() {
        // imageView 설정
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 0.1
        imageView.layer.borderColor = UIColor.gray.cgColor
        
        // 그라데이션 설정
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        let colors: [CGColor] = [
            .init(red: 0, green: 0, blue: 0, alpha: 0.0),
            .init(red: 0, green: 0, blue: 0, alpha: 0.9)
        ]
        gradientLayer.colors = colors
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.6, 1.0]
        imageView.layer.addSublayer(gradientLayer)
        contentView.addSubview(imageView)

        // titleLabel 설정
        titleLabel.textColor = .white
        titleLabel.font = ThemeFont.fontBold(size: 16)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        // bookmarkIcon 설정
        bookmarkIcon.image = UIImage(systemName: "bookmark.fill")
        bookmarkIcon.tintColor = .white
        contentView.addSubview(bookmarkIcon)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }

        bookmarkIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }
    }

    // 셀을 구성하는 함수 (예: 셀을 재사용하기 위한 데이터 설정)
    func configure(with model: BookmarkList) {
        imageView.kf.setImage(with: URL(string: model.imageURL))
        titleLabel.text = model.title
    }
    
    @objc func deselect() {
        bookmarkIconTapped?()
    }
}
