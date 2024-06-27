//
//  CustomAlertViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/15.
//

import UIKit

class CustomAlertViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
extension UIViewController {
    @objc func showCustomAlert(image: UIImage, message: String) {
        print(#function)
        if let existingAlertView = view.subviews.first(where: { $0.tag == 999 }) {
            existingAlertView.removeFromSuperview()
        }
        
        // 사용자 정의 팝업 뷰를 만듭니다.
        let customAlertView = UIView()
        customAlertView.tag = 999
        customAlertView.backgroundColor = ThemeColor.mainOrange
        customAlertView.tintColor = .white
        customAlertView.layer.cornerRadius = 8
        customAlertView.layer.shadowColor = UIColor.black.cgColor
        customAlertView.layer.shadowOpacity = 0.3
        customAlertView.layer.shadowOffset = CGSize(width: 0, height: 5)
        customAlertView.layer.shadowRadius = 8
        
        // 이미지 뷰 설정
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        customAlertView.addSubview(imageView)
        
        // 메시지 레이블 설정
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        customAlertView.addSubview(messageLabel)
        
        self.view.addSubview(customAlertView)
        
        // 제약 조건 설정
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(image.size.width)
            make.height.equalTo(image.size.height)
        }
        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        customAlertView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.centerX.equalToSuperview()
            make.height.equalTo(max(image.size.height, 40))
            make.width.equalTo(image.size.width + messageLabel.intrinsicContentSize.width + 40)
        }
        
        // 알럿 크기를 조절합니다.
        customAlertView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            customAlertView.transform = .identity
        }, completion: { _ in
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                UIView.animate(withDuration: 0.3, animations: {
                    customAlertView.alpha = 0
                }, completion: { _ in
                    customAlertView.removeFromSuperview()
                })
            }
        })
    }
}

