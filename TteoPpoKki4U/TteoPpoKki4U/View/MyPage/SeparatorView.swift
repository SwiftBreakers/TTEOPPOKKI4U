//
//  SeparatorView.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/21/24.
//

import UIKit

class SeparatorView: UICollectionReusableView {
    
    static let identifier = "SeparatorView"
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .lightGray
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
