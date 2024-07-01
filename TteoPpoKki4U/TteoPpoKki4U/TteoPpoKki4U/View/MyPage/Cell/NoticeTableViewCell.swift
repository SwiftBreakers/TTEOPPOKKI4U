//
//  NoticeTableViewCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/24/24.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let detailLabel = UILabel()
    private var foldIconView = UIImageView(image: UIImage(systemName: "chevron.down"))

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.font = ThemeFont.fontBold(size: 18)
        titleLabel.textColor = ThemeColor.mainBlack
        dateLabel.font = ThemeFont.fontRegular(size: 14)
        dateLabel.textColor = .lightGray
        detailLabel.font = ThemeFont.fontMedium(size: 16)
        detailLabel.textColor = ThemeColor.mainBlack
        detailLabel.numberOfLines = 0
        foldIconView.tintColor = .lightGray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(foldIconView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(8)
            make.leading.trailing.equalTo(contentView).inset(20)
        }
        
        foldIconView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(100)
            make.top.equalTo(contentView).inset(8)
            make.trailing.equalTo(contentView).inset(20)
            make.width.height.equalTo(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(contentView).inset(20)
           
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(contentView).inset(16)
            make.bottom.equalTo(contentView).inset(8)
        }
    }
    
    func configure(with notice: Notice, isExpanded: Bool) {
        titleLabel.text = notice.title
        dateLabel.text = notice.date
        detailLabel.text = notice.detail
        detailLabel.isHidden = !isExpanded
        
        if isExpanded {
            detailLabel.snp.remakeConstraints { make in
                make.top.equalTo(dateLabel.snp.bottom).offset(8)
                make.leading.trailing.bottom.equalTo(contentView).inset(16)
            }
            foldIconView.image = UIImage(systemName: "chevron.up")
        } else {
            detailLabel.snp.remakeConstraints { make in
                make.top.equalTo(dateLabel.snp.bottom).offset(0)
                make.leading.trailing.equalTo(contentView).inset(16)
                make.height.equalTo(0) // Set height to 0 when collapsed
            }
            foldIconView.image = UIImage(systemName: "chevron.down")
        }
    }
}
