//
//  ScrapCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/30/24.
//

import UIKit


class ScrapCell: UICollectionViewCell {
    
    weak var delegate: ScrapCellDelegate?
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontBold(size: 17)
        label.textColor = .black
        return label
    }()
    private var addressLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private var deleteButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        deleteButton = UIButton(type: .system)
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
