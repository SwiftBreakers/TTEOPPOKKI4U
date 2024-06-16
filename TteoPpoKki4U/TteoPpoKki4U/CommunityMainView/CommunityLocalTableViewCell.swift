//
//  CommunityLocalTableViewCell.swift
//  TteoPpoKki4U
//
//  Created by 김건응 on 6/13/24.
//

import UIKit
import SnapKit

final class CommunityLocalTableViewCell: UITableViewCell {
    
    //테스트
//    let customLabel: UILabel = {
//            let label = UILabel()
//            label.text = "안녕하세요"
//            label.textAlignment = .center
//            return label
//        }()
    //테스트
    
  
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    lazy var titleLabel2: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 10)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    lazy var container: UIView = {
        let view = UIView()
//
       
        view.addSubview(titleLabel)
        view.addSubview(titleLabel2)
        view.backgroundColor = UIColor(hex: "FFFFFF")
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalTo(titleLabel2.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        titleLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(30)
            
        }
        return view
    }()
//
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(container)
        contentView.backgroundColor = UIColor(hex: "F5F5F5")
        container.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-20)
//            $0.width.equalTo(300)
            $0.bottom.equalToSuperview()
        }
        container.layer.cornerRadius = 4
        
        
        
    }
    required init?(coder: NSCoder) { nil }
    
}
