//
//  CustomTextView.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/16/24.
//

import UIKit

class CustomTextView: UITextView {
    
    init(keyboardType: UIKeyboardType = .default, target: Any?, action: Selector) {
        super.init(frame: .zero, textContainer: nil)
        
        self.keyboardType = keyboardType
        self.font = UIFont.systemFont(ofSize: 16)
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.7364070391, green: 0.7364070391, blue: 0.7364070391, alpha: 1).cgColor
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIView().frame.size.width, height: 36))
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: target,
            action: action)
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
        ]
        
        toolBar.isUserInteractionEnabled = true
        inputAccessoryView = toolBar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
