//
//  UICollectionView+Extension.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 6/20/24.
//

import UIKit
import SnapKit

// 단어장 데이터가 없을 때(0) 나타나는 메시지
extension UICollectionView {

    func setEmptyMsg(_ msg: String) {
        let container = UIView()
        let msgLabel: UILabel = {
            let label = UILabel()
            label.text = msg
            label.textColor = .gray
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = ThemeFont.fontRegular()
            label.sizeToFit()
            return label
        }()
        container.addSubview(msgLabel)
        self.backgroundView = container
        
        msgLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(250)
        }
    }

    func restore() {
        self.backgroundView = nil
    }
}
