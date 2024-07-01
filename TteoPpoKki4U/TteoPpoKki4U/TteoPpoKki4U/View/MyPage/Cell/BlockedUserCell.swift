//
//  BlockedUserCell.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/30/24.
//

import UIKit
import SnapKit

class BlockedUserCell: UITableViewCell {
    
    let unblockButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("차단 해제", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let userIdLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        contentView.addSubview(userIdLabel)
        contentView.addSubview(unblockButton)
        
        userIdLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).offset(16)
        }
        
        unblockButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-16)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with userId: String) {
        userIdLabel.text = userId
    }
}
