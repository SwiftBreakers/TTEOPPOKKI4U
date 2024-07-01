//
//  CustomMessageContentCell.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 7/1/24.
//

import UIKit
import MessageKit

class CustomMessageContentCell: MessageContentCell {
    let customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }
    
    private func setupImageView() {
        messageContainerView.addSubview(customImageView)
        NSLayoutConstraint.activate([
            customImageView.topAnchor.constraint(equalTo: messageContainerView.topAnchor),
            customImageView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor),
            customImageView.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor),
            customImageView.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor)
        ])
    }
}
