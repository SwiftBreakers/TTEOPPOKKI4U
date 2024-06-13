//
//  GreetingBottomView.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/12/24.
//

import UIKit
import SnapKit

class GreetingBottomView: UIView {
    
    private lazy var hiddenView: UIView = {
        let view = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenDidtapped))
        view.backgroundColor = .white
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        return view
    }()
    
    var hiddenTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        self.addSubview(hiddenView)
        
        hiddenView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-300)
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func hiddenDidtapped() {
        hiddenTapped?()
    }
}

