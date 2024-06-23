//
//  ChannelTableViewCell.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/20.
//

import UIKit
import SnapKit

class ChannelTableViewCell: UITableViewCell {
    lazy var chatRoomLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.mainBlack
        label.font = ThemeFont.fontMedium(size: 18)
        return label
    }()
    
    lazy var detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.isUserInteractionEnabled = false
        button.tintColor = .gray
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configure() {
        contentView.addSubview(chatRoomLabel)
        contentView.addSubview(detailButton)
        
        chatRoomLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(detailButton).offset(-24)
        }
        
        detailButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        detailButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-24)
        }
    }
}

