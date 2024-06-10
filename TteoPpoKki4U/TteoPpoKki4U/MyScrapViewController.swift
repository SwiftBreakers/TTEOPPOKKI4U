//
//  MyScrapViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/30/24.
//

import UIKit
import SnapKit

class MyScrapViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var scrapLists: [ScrapList] = [
        ScrapList(storeId: UUID(), store: "Scrap 1", rating: 0.0, address: "Description 1"),
        ScrapList(storeId: UUID(), store: "Scrap 2", rating: 0.0, address: "Description 2")
        //스크랩 항목 만들기
    ]
    
    var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.backward.2")
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.addTarget(nil, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        setupBackButton() // backButton을 먼저 설정
        setupCollectionView()
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        
    }
    
    func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-340)
            make.height.equalTo(30)
        }
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 100)
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ScrapCell.self, forCellWithReuseIdentifier: "ScrapCell")
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func deleteScrap(at indexPath: IndexPath) {
        scrapLists.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
    }
}

extension MyScrapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scrapLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrapCell", for: indexPath) as! ScrapCell
        let scrapItem = scrapLists[indexPath.item]
        cell.configure(with: scrapItem)
        cell.delegate = self
        return cell
    }
}

extension MyScrapViewController: ScrapCellDelegate {
    func didTapDeleteButton(on cell: ScrapCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            deleteScrap(at: indexPath)
        }
    }
}

// MARK: - ScrapCell
protocol ScrapCellDelegate: AnyObject {
    func didTapDeleteButton(on cell: ScrapCell)
}

