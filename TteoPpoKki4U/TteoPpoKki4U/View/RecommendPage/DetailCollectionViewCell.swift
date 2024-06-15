//
//  DetailCollectionViewCell.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/15.
//

import UIKit
import SnapKit

class DetailCollectionViewCell: UICollectionViewCell {
    static let identifier = "DetailCollectionViewCell"
    
    private let view: UIView = {
        let view = UIView()
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
        
        self.contentView.addSubview(self.view)
        self.contentView.addSubview(self.dimmedView)
        
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.prepare(color: nil, isDimmed: true)
    }
    
    func prepare(color: UIColor?, isDimmed: Bool) {
        self.view.backgroundColor = color
        self.dimmedView.isHidden = !isDimmed
    }
}



