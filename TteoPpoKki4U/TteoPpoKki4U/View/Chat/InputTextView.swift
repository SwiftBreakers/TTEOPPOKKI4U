//
//  InputTextView.swift
//  ChatApp
//
//  Created by Dongik Song on 6/6/24.
//

import UIKit

class InputTextView: UITextView {
    
    let placeHolderLabel = CustomLabel(text: "   Type a message...", labelColor: .lightGray)
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = #colorLiteral(red: 0.9656843543, green: 0.9657825828, blue: 0.9688259959, alpha: 1)
        layer.cornerRadius = 20
        isScrollEnabled = false
        font = .systemFont(ofSize: 16)
        
        addSubview(placeHolderLabel)
        placeHolderLabel.centerY(inView: self, leftAnchor: leftAnchor, rightAnchor: rightAnchor, paddingLeft: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
        
        paddingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTextDidChange() {
        placeHolderLabel.isHidden = !text.isEmpty
    }
}

extension UITextView {
    func paddingView() {
        self.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    }
}
