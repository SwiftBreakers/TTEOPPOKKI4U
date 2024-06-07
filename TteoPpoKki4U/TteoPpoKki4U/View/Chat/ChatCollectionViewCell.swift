//
//  ChatCollectionViewCell.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/7/24.
//

import UIKit

class ChatCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
  
    
    private let profileImageView = CustomImageView(width: 30, height: 30, backgroundColor: .lightGray, cornerRadius: 15)
    
    private let datelabel = CustomLabel(text: "10/10/2020", textFont: .systemFont(ofSize: 12), labelColor: .lightGray)
    
    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9245408177, green: 0.9278380275, blue: 0.9309870005, alpha: 1)
        return view
    }()
    
    var bubbleRightAnchor: NSLayoutConstraint!
    var bubbleLeftAnchor: NSLayoutConstraint!
    
    var dateRightAnchor: NSLayoutConstraint!
    var dateLeftAnchor: NSLayoutConstraint!
    
    private let textView: UITextView = {
        let tf = UITextView()
        tf.backgroundColor = .clear
        tf.isEditable = false
        tf.isScrollEnabled = false
        tf.text = "Sample Data"
        tf.font = .systemFont(ofSize: 16)
        return tf
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 10)
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleLeftAnchor.isActive = false
        
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleRightAnchor.isActive = false
        
        addSubview(datelabel)
        
        dateLeftAnchor = datelabel.leftAnchor.constraint(equalTo: bubbleContainer.rightAnchor, constant: 12)
        dateLeftAnchor.isActive = false
        
        dateRightAnchor = datelabel.rightAnchor.constraint(equalTo: bubbleContainer.leftAnchor, constant: -12)
        dateRightAnchor.isActive = false
        
        datelabel.anchor(bottom: bottomAnchor)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
}
