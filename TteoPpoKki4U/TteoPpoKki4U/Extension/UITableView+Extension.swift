//
//  UITableView+Extension.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 6/20/24.
//

import UIKit
import SnapKit

extension UITableView {
    
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
            make.center.equalToSuperview()
        }
    }

    func restore() {
        self.backgroundView = nil
    }
}
