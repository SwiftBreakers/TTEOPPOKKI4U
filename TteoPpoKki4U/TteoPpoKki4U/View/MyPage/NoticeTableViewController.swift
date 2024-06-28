//
//  NoticeTableViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/24/24.
//

import UIKit
import SnapKit

class NoticeTableViewController: UITableViewController {
    
    var notices = [
        Notice(title: "[업데이트] 커뮤니티", date: "2024.06.28", detail: "안녕하세요. 커뮤니티에서 사진과 지도를 공유할 수 있는 기능이 추가되었습니다."),
        Notice(title: "[업데이트] 커뮤니티 탭", date: "2024.06.26", detail: "안녕하세요. 커뮤니티 기능이 새롭게 업데이트 되었습니다. 앱 개선을 위해 앞으로도 꾸준히 노력하겠습니다. 감사합니다."),
        Notice(title: "[업데이트] 공지사항", date: "2024.06.26", detail: "안녕하세요. 공지사항 버튼이 생기게 되어 첫번째 공지사항을 올립니다. 이용해 주셔서 감사합니다.")
    ]
    
    var expandedIndexSet: IndexSet = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = ThemeColor.mainOrange
        navigationController?.navigationBar.barTintColor = .white
        
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeCell")
      //  tableView.estimatedRowHeight = 100
     //   tableView.rowHeight = UITableView.automaticDimension
        tableView.rowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as? NoticeTableViewCell else {
            return UITableViewCell()
        }
        let notice = notices[indexPath.row]
        cell.configure(with: notice, isExpanded: expandedIndexSet.contains(indexPath.row))
        return cell
    }
    
    // MARK: - Table view delegate
    
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
