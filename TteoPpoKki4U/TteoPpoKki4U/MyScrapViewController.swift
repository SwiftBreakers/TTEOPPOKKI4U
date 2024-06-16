//
//  MyScrapViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/30/24.
//

import UIKit
import SnapKit
import Combine
import FirebaseAuth
import ProgressHUD

class MyScrapViewController: UIViewController {
    
    var segmentedControl: UISegmentedControl!
    var collectionView: UICollectionView!
    
    var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.backward.2")
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.addTarget(nil, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let scrapViewModel = ScrapViewModel()
    let bookmarkViewModel = BookmarkViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        setupBackButton()
        setupSegmentedControl()
        setupCollectionView()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
        bind()
    }
    
    private func getData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        scrapViewModel.fetchScrap(uid: uid)
    }
    
    private func bind() {
        scrapViewModel.$scrapArray
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        scrapViewModel.scrapPublisher.sink { [weak self] completion in
            switch completion {
            case .finished: return
            case .failure(let error): self?.showMessage(title: "에러 발생", message: "\(error)")
            }
        } receiveValue: { _ in
            
        }.store(in: &cancellables)
        
        bookmarkViewModel.$bookmarkArray
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
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
    
    func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["스크랩", "북마크"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        view.addSubview(segmentedControl)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
    }
    
    @objc func segmentChanged(sender: UISegmentedControl) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        switch sender.selectedSegmentIndex {
        case 0: scrapViewModel.fetchScrap(uid: uid)
        case 1: bookmarkViewModel.fetchBookmark(uid: uid)
        default: return
        }
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ScrapCell.self, forCellWithReuseIdentifier: "ScrapCell")
        collectionView.register(BookmarkCell.self, forCellWithReuseIdentifier: "BookmarkCell")
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    func deleteScrap(at indexPath: IndexPath) {
        let item = scrapViewModel.scrapArray[indexPath.row]
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        scrapViewModel.deleteScrap(uid: uid, shopAddress: item.shopAddress) { [weak self] in
            self?.getData()
        }
    }
}

extension MyScrapViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? scrapViewModel.scrapArray.count : bookmarkViewModel.bookmarkArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrapCell", for: indexPath) as! ScrapCell
            let scrapItem = scrapViewModel.scrapArray[indexPath.row]
            cell.configure(with: scrapItem)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkCell", for: indexPath) as! BookmarkCell
            let bookmarkItem = bookmarkViewModel.bookmarkArray[indexPath.item]
            cell.configure(with: bookmarkItem)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if segmentedControl.selectedSegmentIndex == 0 {
            return CGSize(width: view.frame.width - 20, height: 100)
        } else {
            let numberOfItemsPerRow: CGFloat = 2
            
            let width = (collectionView.bounds.width - 18) / numberOfItemsPerRow
            return CGSize(width: width, height: width * 1.5)
        }
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
