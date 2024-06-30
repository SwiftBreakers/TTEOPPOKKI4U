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
    
//    var backButton: UIButton = {
//        let button = UIButton(type: .system)
//        let image = UIImage(systemName: "chevron.backward.2")
//        button.setImage(image, for: .normal)
//        button.tintColor = .gray
//        button.addTarget(nil, action: #selector(backButtonTapped), for: .touchUpInside)
//        return button
//    }()
    var defaultView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "ttukbokki4u1n")
        return image
    }()
    
    let scrapViewModel = ScrapViewModel()
    let bookmarkViewModel = BookmarkViewModel()
    let cardViewModel = CardViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
//        setupBackButton()
        navigationController?.navigationBar.tintColor = ThemeColor.mainOrange
        navigationController?.navigationBar.barTintColor = .white
        
        setupSegmentedControl()
        setupCollectionView()
       // navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
        bind()
    }
    
    deinit{
        cancellables.removeAll()
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
            .sink { array in
                if array.count == 0 {
                    self.collectionView.setEmptyMsg(" 아직 스크랩한 가게가 없어요!\n가게들을 찾아 스크랩해 보세요.")
                    self.collectionView.reloadData()
                } else {
                    self.collectionView.restore()
                    self.collectionView.reloadData()
                }
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
            .sink { array in
                if array.count == 0 {
                    self.collectionView.setEmptyMsg("아직 북마크한 추천글이 없어요!\n추천글을 읽고 북마크해 보세요.")
                    self.collectionView.reloadData()
                } else {
                    self.collectionView.restore()
                    self.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
//    func setupBackButton() {
//        view.addSubview(backButton)
//        
//        backButton.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-340)
//            make.height.equalTo(30)
//        }
//    }
    
    func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["스크랩", "북마크"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        if traitCollection.userInterfaceStyle == .dark {
            segmentedControl.backgroundColor = .clear
            segmentedControl.selectedSegmentTintColor = .white
                let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
                segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
            } else {
                segmentedControl.backgroundColor = .clear
                segmentedControl.selectedSegmentTintColor = .white
                let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
                segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
            }
        
        view.addSubview(segmentedControl)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(35)
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
            cell.bookmarkIconTapped = { [weak self] in
                guard let uid = Auth.auth().currentUser?.uid else {
                    return
                }
                self?.bookmarkViewModel.deleteBookmark(uid: uid, title: bookmarkItem.title, completion: {
                    self?.bookmarkViewModel.fetchBookmark(uid: uid)
                })
            }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            
        } else {
            
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
