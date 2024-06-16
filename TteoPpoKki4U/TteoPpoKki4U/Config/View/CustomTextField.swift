//
//  CustomTextField.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/16/24.
//

import UIKit

class CustomTextField: UITextField {
    
    init(placeholder: String, keyboardType: UIKeyboardType = .default, target: Any?, action: Selector) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        leftViewMode = .always
        borderStyle = .none
        textColor = .black
        keyboardAppearance = .light
        clearButtonMode = .whileEditing
        autocorrectionType = .no
        spellCheckingType = .no
        
        self.keyboardType = keyboardType
        
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
