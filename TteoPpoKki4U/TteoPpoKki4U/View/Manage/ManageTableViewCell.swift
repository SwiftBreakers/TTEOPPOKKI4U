//
//  ManageTableViewCell.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/12/24.
//

import UIKit
import SnapKit

class ManageTableViewCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var setButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("차단", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(deactivate), for: .touchUpInside)
        return button
    }()
    
    private lazy var unsetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("해제", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(activate), for: .touchUpInside)
        return button
    }()
    
    var deactivateTapped: (() -> Void)?
    var activateTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [titleLabel, setButton, unsetButton].forEach { view in
            contentView.addSubview(view)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(250)
        }
        
        setButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(30)
        }
        
        unsetButton.snp.makeConstraints { make in
            make.leading.equalTo(setButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    @objc func deactivate() {
        deactivateTapped?()
    }
    
    @objc func activate() {
        activateTapped?()
    }
}
