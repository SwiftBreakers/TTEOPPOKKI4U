//
//  ReviewTableViewCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/5/24.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    lazy var reviewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium()
        label.textColor = ThemeColor.mainBlack
        label.sizeToFit()
        return label
    }()
    
    lazy var starRatingLabel : UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 14)
        label.textColor = ThemeColor.mainBlack
        label.sizeToFit()
        return label
    }()
    
    lazy var createdAtLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 12)
        label.textColor = .gray
        label.sizeToFit()
        return label
    }()
    
    lazy var thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.skeletonCornerRadius = 10
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        self.separatorInset.left = 15
        self.separatorInset.right = 15
        contentView.addSubview(reviewTitleLabel)
        contentView.addSubview(starRatingLabel)
        contentView.addSubview(createdAtLabel)
        contentView.addSubview(thumbnailImage)
        
        reviewTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalTo(thumbnailImage.snp.leading).inset(-20)
        }
        
        starRatingLabel.snp.makeConstraints { make in
            make.top.equalTo(reviewTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(reviewTitleLabel.snp.leading)
        }
        
        createdAtLabel.snp.makeConstraints { make in
            make.leading.equalTo(starRatingLabel.snp.trailing).offset(10)
            make.centerY.equalTo(starRatingLabel)
            make.bottom.equalToSuperview().inset(10)
        }
        
        thumbnailImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(25)
            make.width.equalTo(thumbnailImage.snp.height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImage.image = nil
    }
}
