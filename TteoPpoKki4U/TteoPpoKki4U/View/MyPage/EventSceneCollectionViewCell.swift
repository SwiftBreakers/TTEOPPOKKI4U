//
//  EventSceneCollectionViewCell.swift
//  TteoPpoKki4U
//
//  Created by 김건응 on 6/27/24.
//

import Foundation
import UIKit
import SnapKit

class EventSceneCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}

