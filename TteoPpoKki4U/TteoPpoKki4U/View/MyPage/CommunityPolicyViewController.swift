//
//  CommunityPolicyViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/28/24.
//

import UIKit
import SnapKit

class CommunityPolicyViewController: UIViewController {
    
    var textView: UITextView = {
        
        let text = UITextView()
        text.textColor = ThemeColor.mainBlack
        text.backgroundColor = .white
        return text
        
    }()
    
    var label: UILabel = {
        let text = UILabel()
        text.textColor = ThemeColor.mainBlack
        return text
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTopLabel()
        setupTextView()
        
        navigationController?.navigationBar.tintColor = ThemeColor.mainOrange
        
        
    }
    
    
    func setupTopLabel() {
        label.text = "커뮤니티 이용약관"
        view.addSubview(label)
        
        label.font = ThemeFont.fontBold(size: 20)
        label.textColor = ThemeColor.mainBlack
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(120)
            make.centerX.equalToSuperview()
        }
    }
    
    
    func setupTextView() {
        textView.text = CommunityPolicy().policy
        view.addSubview(textView)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8 // 원하는 행간 값 설정
        
        let attributedString = NSMutableAttributedString(string: CommunityPolicy().policy, attributes: [
            .font: ThemeFont.fontRegular(size: 14), // 폰트 설정
            .paragraphStyle: paragraphStyle // 행간 설정
        ])
        
        textView.attributedText = attributedString
        textView.textColor = ThemeColor.mainBlack
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        textView.isEditable = false
    }
    
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        
    }
    
    
}
