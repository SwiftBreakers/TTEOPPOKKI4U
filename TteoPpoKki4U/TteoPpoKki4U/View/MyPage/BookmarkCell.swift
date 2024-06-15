//
//  BookmarkCollectionViewCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/14/24.
//

import UIKit
import Kingfisher

class BookmarkCell: UICollectionViewCell {
    
//    weak var delegate: BookmarkCellDelegate?
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
            contentView.addSubview(imageView)

            // titleLabel 설정
            titleLabel.textColor = .white
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            titleLabel.numberOfLines = 1
            contentView.addSubview(titleLabel)

            // bookmarkIcon 설정
            bookmarkIcon.image = UIImage(systemName: "bookmark.fill") // 시스템 이미지를 사용하는 경우
            bookmarkIcon.tintColor = .white
            contentView.addSubview(bookmarkIcon)

            // SnapKit을 사용하여 레이아웃 설정
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(8)
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
