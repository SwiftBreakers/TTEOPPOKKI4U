//
//  NoticeTableViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/24/24.
//

import UIKit
import SnapKit
import Combine

class NoticeTableViewController: UITableViewController {
    
    var expandedIndexSet: IndexSet = []
    var viewModel: ManageViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let manageManager = ManageManager()
        viewModel = ManageViewModel(manageManager: manageManager)
        viewModel.getNotices()
        bind()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = ThemeColor.mainOrange
        navigationController?.navigationBar.barTintColor = .white
        
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeCell")
        tableView.rowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func bind() {
        viewModel.$noticeArray
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notices in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.noticeArray.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as? NoticeTableViewCell else {
            return UITableViewCell()
        }
        let notice = viewModel.noticeArray[indexPath.row]
        cell.configure(with: notice, isExpanded: expandedIndexSet.contains(indexPath.row))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedIndexSet.contains(indexPath.row) {
            expandedIndexSet.remove(indexPath.row)
        } else {
            expandedIndexSet.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return expandedIndexSet.contains(indexPath.row) ? UITableView.automaticDimension : 60
    }
}
