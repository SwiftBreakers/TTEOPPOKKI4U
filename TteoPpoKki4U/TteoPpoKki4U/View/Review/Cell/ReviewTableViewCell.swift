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
        label.font = ThemeFont.fontRegular(size: 17)
        label.textColor = .black
        return label
    }()
    
    lazy var starRatingLabel : UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 17)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        contentView.addSubview(reviewTitleLabel)
        contentView.addSubview(starRatingLabel)
        
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
