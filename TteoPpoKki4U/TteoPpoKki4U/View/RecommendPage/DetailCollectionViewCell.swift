//
//  DetailCollectionViewCell.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/15.
//

import UIKit
import SnapKit
import Kingfisher

class DetailCollectionViewCell: UICollectionViewCell {
    static let identifier = "DetailCollectionViewCell"

    private var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.45)
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.dimmedView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.prepare(imageURL: nil, isDimmed: true)
    }

    func prepare(imageURL: URL?, isDimmed: Bool) {
            if let imageURL = imageURL {
                self.imageView.kf.setImage(with: imageURL)
            } else {
                self.imageView.image = nil
            }
            self.dimmedView.isHidden = !isDimmed
        }
}



