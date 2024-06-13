//
//  ReviewTableViewCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/5/24.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    let reviewTitleLabel = UILabel()
    let starRatingLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(reviewTitleLabel)
        contentView.addSubview(starRatingLabel)
        
        reviewTitleLabel.font = ThemeFont.fontRegular(size: 17)
        starRatingLabel.font = ThemeFont.fontRegular(size: 17)
        
        reviewTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        starRatingLabel.snp.makeConstraints { make in
            make.leading.equalTo(reviewTitleLabel.snp.trailing).offset(10)
            make.centerY.equalTo(reviewTitleLabel)
            make.trailing.equalToSuperview().inset(20)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
