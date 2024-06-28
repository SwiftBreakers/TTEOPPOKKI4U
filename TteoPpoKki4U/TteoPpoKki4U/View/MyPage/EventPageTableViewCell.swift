//
//  EventPageTableViewCell.swift
//  TteoPpoKki4U
//
//  Created by 김건응 on 6/25/24.
//

import Foundation
import UIKit
import SnapKit

class EventPageTableViewCell: UITableViewCell {
    
    let containerView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 5
        view.clipsToBounds = true
        return view
        
    }()
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 16)
        label.textColor = .white
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let gradientLayer: CAGradientLayer = {
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.2).cgColor]
        gradient.locations = [0.5, 1.0]
            return gradient
        }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }
    
    func setupViews() {
        contentView.addSubview(containerView)

        containerView.addSubview(eventImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        contentView.backgroundColor = UIColor(hexString: "ECECEC")
        eventImageView.layer.addSublayer(gradientLayer)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.height.equalTo(100)
        }
        
        eventImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.equalTo(containerView.snp.leading).offset(30)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalTo(containerView.snp.leading).offset(30)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
    }
    
    func configure(with title: String, description: String, image: UIImage?) {
        titleLabel.text = title
        descriptionLabel.text = description
        eventImageView.image = image
    }
}

