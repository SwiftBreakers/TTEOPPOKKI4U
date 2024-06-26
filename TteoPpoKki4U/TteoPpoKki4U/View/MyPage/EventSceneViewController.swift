//
//  EventSceneViewController.swift
//  TteoPpoKki4U
//
//  Created by 김건응 on 6/26/24.
//

import Foundation
import UIKit
import SnapKit

class EventSceneViewController: UIViewController {
    
    let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 24)
            label.textColor = .black
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()
        
        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 18)
            label.textColor = .darkGray
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            setupViews()
        }
        
        func setupViews() {
            view.addSubview(titleLabel)
            view.addSubview(descriptionLabel)
            
            titleLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
            }
            
            descriptionLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
            }
        }
        
        func configure(with title: String, description: String) {
            titleLabel.text = title
            descriptionLabel.text = description
        }
    
}
