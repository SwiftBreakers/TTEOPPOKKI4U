//
//  RecommendCardView.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/05/30.
//

import UIKit
import VerticalCardSwiper
import SnapKit

public class MyCardCell: CardCell {
    
    public let titleLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setCardUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.bottom.equalTo(descriptionLabel.snp.bottom).inset(35)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().inset(60)
        }
    }
    
    public func setCardUI() {
        titleLabel.font = ThemeFont.fontBold(size: 40)
        titleLabel.textColor = .white
        
        descriptionLabel.font = ThemeFont.fontRegular(size: 16)
        descriptionLabel.textColor = .white
        
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        
        self.layer.cornerRadius = 12
    }
}
