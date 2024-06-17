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
        
        titleLabel.font = ThemeFont.fontBold(size: 17)
        addressLabel.font = ThemeFont.fontMedium(size: 14)
        addressLabel.numberOfLines = 0
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .lightGray
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(deleteButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-10)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(titleLabel)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
    func configure(with item: ScrapList) {
        titleLabel.text = item.shopName
        addressLabel.text = item.shopAddress
    }
    
    @objc func deleteButtonTapped() {
        delegate?.didTapDeleteButton(on: self)
    }
}
