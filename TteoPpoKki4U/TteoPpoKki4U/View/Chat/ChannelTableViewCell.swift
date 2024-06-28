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
    lazy var myLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.mainOrange
        label.font = ThemeFont.fontMedium(size: 18)
        return label
    }()
    lazy var countView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.mainOrange
        view.layer.cornerRadius = 12
        return view
    }()
    lazy var detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.isUserInteractionEnabled = false
        button.tintColor = .gray
        return button
    }()
    lazy var threadCountLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = ThemeFont.fontMedium(size: 18)
        return label
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
        contentView.addSubview(myLabel)
        contentView.addSubview(detailButton)
        contentView.addSubview(countView)
        countView.addSubview(threadCountLabel)
        
        chatRoomLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(countView).offset(-24)
        }
        
        myLabel.snp.makeConstraints { make in
            make.leading.equalTo(chatRoomLabel.snp.trailing).offset(40)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(countView).offset(-24)
        }
        
        detailButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        detailButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-24)
        }
        
        countView.snp.makeConstraints { make in
            make.trailing.equalTo(detailButton.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
        }
        
        threadCountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6))  // 레이블과 뷰 사이의 패딩 설정
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myLabel.text = nil
        
        threadCountLabel.text = nil
    }

}

