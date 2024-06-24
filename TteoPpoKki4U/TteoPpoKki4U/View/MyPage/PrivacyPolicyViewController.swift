//
//  PrivacyPolicyViewController.swift
//  TteoPpoKki4U
//
//  Created by 김건응 on 6/21/24.
//

import Foundation
import UIKit
import SnapKit

class PrivacyPolicyViewController: UIViewController, UIScrollViewDelegate {
    
    var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.backward.2")
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.addTarget(nil, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
   
    var textView: UITextView = {
        
        let text = UITextView()
        text.textColor = .black
        
        return text
        
    }()
    
    var label: UILabel = {
       let text = UILabel()
        text.textColor = .black
        return text
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white  // 배경색 설정
       
        setupBackButton()
        setupTextView()
        setupTopLabel()
    


        
    }
    
  
    func setupTopLabel() {
        label.text = "이용약관"
        view.addSubview(label)
        
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(hex: "353535")
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(75)
            make.centerX.equalToSuperview()
        }
    }
    
    
    func setupTextView() {
        textView.text = privacyPolicyText().privacytext
        view.addSubview(textView)
        
        let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8 // 원하는 행간 값 설정

            let attributedString = NSMutableAttributedString(string: privacyPolicyText().privacytext, attributes: [
                .font: UIFont.systemFont(ofSize: 14), // 폰트 설정
                .paragraphStyle: paragraphStyle // 행간 설정
            ])
            
            textView.attributedText = attributedString
        textView.textColor = UIColor(hex: "353535")
       
        textView.snp.makeConstraints { make in
//            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        textView.isEditable = false
    }
    
//    func setupViews() {
//        // 여기에 뷰 구성 요소를 추가
//        let label = UILabel()
//        label.text = "Privacy Policy"
//        label.textAlignment = .center
//        label.frame = CGRect(x: 0, y: 200, width: view.bounds.width, height: 50)
//        view.addSubview(label)
//        label.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(25)
//            make.trailing.equalToSuperview().offset(-25)
//            make.bottom.equalTo(label.snp.bottom).inset(35)
//        }
//    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        
    }
    func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-340)
            make.height.equalTo(30)
        }
    }
    
}


//UIColor을 확장하여 hex color을 쓰기 위해 지원하도록 하는 코드
//extension UIColor {
//    convenience init(hex: String, alpha: CGFloat = 1.0) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//                hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//
//                var rgb: UInt64 = 0
//
//                Scanner(string: hexSanitized).scanHexInt64(&rgb)
//
//                let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//                let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//                let blue = CGFloat(rgb & 0x0000FF) / 255.0
//
//                self.init(red: red, green: green, blue: blue, alpha: alpha)
//            }
//    
//    
//}