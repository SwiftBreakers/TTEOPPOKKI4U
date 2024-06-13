//
//  ManageView.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/12/24.
//

import UIKit

class ManageView: UIView {
    
    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["유져", "게시글"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.isUserInteractionEnabled = true
        table.register(ManageTableViewCell.self, forCellReuseIdentifier: "ManageTableViewCell")
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.addSubview(segmentedControl)
        self.addSubview(tableView)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(10)
            make.leading.trailing.equalTo(self).inset(10)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(self)
        }
    }
    
}
