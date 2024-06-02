//
//  ScrapCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/30/24.
//

import UIKit


class ScrapCell: UICollectionViewCell {
    
    weak var delegate: ScrapCellDelegate?
    private var titleLabel: UILabel!
    private var addressLabel: UILabel!
    private var deleteButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        titleLabel = UILabel()
        addressLabel = UILabel()
        deleteButton = UIButton(type: .system)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.numberOfLines = 0
        deleteButton.setTitle("삭제", for: .normal)
        deleteButton.titleLabel?.font = UIFont(name: ThemeFont.fontMedium, size: 17)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(deleteButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-10)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalTo(titleLabel)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
    }
    
    func configure(with item: ScrapList) {
        titleLabel.text = item.store
        addressLabel.text = item.address
    }
    
    @objc func deleteButtonTapped() {
        delegate?.didTapDeleteButton(on: self)
    }
}
