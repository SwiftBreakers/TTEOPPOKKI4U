//
//  CustomLabel.swift
//  ChatApp
//
//  Created by Dongik Song on 6/5/24.
//

import UIKit

class CustomLabel: UILabel {
    
    init(text: String, textFont: UIFont = .systemFont(ofSize: 14), labelColor: UIColor = .black) {
        super.init(frame: .zero)
        
        self.text = text
        font = textFont
        textColor = labelColor
        
        textAlignment = .center
        numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
