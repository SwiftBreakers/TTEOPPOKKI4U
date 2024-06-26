//
//  EventPageViewController.swift
//  TteoPpoKki4U
//
//  Created by 김건응 on 6/24/24.
//

import Foundation
import UIKit
import SnapKit


class EventPageViewController: UIViewController {
    
    var tableView: UITableView!
    
    var eventData: [EventData] = [
    EventData(title: "떡볶이 먹고 커피도 마시고!", description: "떡볶이로 매운 입가를 달래줄 추첨 이벤트", image: UIImage(named: "sample"))
    ]
    
    var backButton: UIButton = {
        
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.backward.2")
        button.tintColor = .gray
        button.setImage(image, for: .normal)

        button.addTarget(nil, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
       
    }()
    
    var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "이벤트"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    var customNavigationBar: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        
        return view
        
    }()
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white  // 배경색 설정
        
        setupCustomNavigationBar()

        setupTableView()
        setupBackButton()
       
        
    }
    
    func setupCustomNavigationBar() {
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
            
        }
        
        customNavigationBar.addSubview(backButton)
        customNavigationBar.addSubview(titleLabel)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-340)
            make.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        
        
    }
    
    
    func setupTableView() {
        
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(hexString: "F7F7F7")
        
        
        
        tableView.register(EventPageTableViewCell.self, forCellReuseIdentifier: "EventPageCell")
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    
    
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        
    }
    func setupBackButton() {
        
        navigationController?.isNavigationBarHidden = true
//        navigationController?.popViewController(animated: true)

        
    }
    
    
    
}
extension EventPageViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventPageCell", for: indexPath) as? EventPageTableViewCell else {
            return UITableViewCell()
        }
        
        let event = eventData[indexPath.row]
        cell.configure(with: event.title, description: event.description, image: event.image)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedEvent = eventData[indexPath.row]
            let detailVC = EventSceneViewController()
//            detailVC.configure(with: selectedEvent.title, description: selectedEvent.description)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    
}
