//
//  CustomInputView.swift
//  ChatApp
//
//  Created by Dongik Song on 6/6/24.
//

import UIKit

protocol CustomInputViewDelegate: AnyObject {
    func inputView(_ view: CustomInputView, wantUploadMessage message: String)
}

class CustomInputView: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomInputViewDelegate?
    let inputTextView = InputTextView()
    
    private let postBackgroundColor: CustomImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePostButton))
        let iv = CustomImageView(width: 40, height: 40, backgroundColor: .red, cornerRadius: 20)
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePostButton), for: .touchUpInside)
        button.setDimensions(height: 28, width: 28)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [inputTextView, postBackgroundColor])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingLeft: 5, paddingRight: 5)
        
        addSubview(postButton)
        postButton.center(inView: postBackgroundColor)
        
        
        inputTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: postBackgroundColor.leftAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 5, paddingRight: 8)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .lightGray
        addSubview(dividerView)
        dividerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        
        return .zero
    }
    
    // MARK: - Helpers
    @objc func handlePostButton() {
        delegate?.inputView(self, wantUploadMessage: inputTextView.text)
    }
    
    func clearTextView() {
        inputTextView.text = ""
        inputTextView.placeHolderLabel.isHidden = false
    }
}
