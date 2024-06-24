//
//  BookmarkCollectionViewCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/14/24.
//

import UIKit
import Kingfisher

import UIKit
import Kingfisher

class BookmarkCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let bookmarkIcon = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
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
}
