//
//  GreetingViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/30/24.
//

import UIKit
import SnapKit

class GreetingViewController: UIViewController {

    
    let greetingHeaderView = GreetingHeaderView()
    let greetingBodyView = GreetingBodyView()

    lazy var vStackview: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            UIView(),
            greetingHeaderView,
            greetingBodyView
        ])
        stackView.axis = .vertical
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        
    }
    
    func setupLayout() {
        view.addSubview(vStackview)
        
        vStackview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        greetingHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        greetingBodyView.snp.makeConstraints { make in
            make.top.equalTo(greetingHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    

}
