//
//  MyReviewViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/30/24.
//
import UIKit
import SnapKit
import Combine

class MyReviewViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ReviewCell.self, forCellWithReuseIdentifier: ReviewCell.identifier)
        return collectionView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.backward.2")
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    let viewModel = ReviewViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        bind()
    }
    
    private func getData() {
        viewModel.getUserReview()
    }
    
    private func bind() {
        viewModel.$userReview
            .sink { _ in
                self.collectionView.reloadData()
            }.store(in: &cancellables)
        
        viewModel.reviewPublisher.sink { completion in
            switch completion {
            case .finished:
                return
            case .failure(let error):
                print(error)
            }
        } receiveValue: { _ in
        }.store(in: &cancellables)
        
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionView Datasource and Delegate Methods
extension MyReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.userReview.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.identifier, for: indexPath) as! ReviewCell
        
        cell.configure(with: viewModel.userReview[indexPath.item], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200)
    }
}

extension MyReviewViewController: ReviewCellDelegate {
    func editReview(_ review: ReviewModel, indexPath: IndexPath) {
        let writeVC = WriteViewController()
        let item = viewModel.userReview[indexPath.row]
        writeVC.isEditMode = true
        writeVC.isNavagtion = true
        writeVC.review = item
        
        navigationController?.pushViewController(writeVC, animated: true)
    }
    
    func deleteReview(_ review: ReviewModel, indexPath: IndexPath) {
        let item = viewModel.userReview[indexPath.row]
        let alert = UIAlertController(title: "삭제 확인", message: "삭제하시면 복원 할 수 없습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { [unowned self] _ in
            viewModel.removeUserReview(uid: item.uid, storeAddress: item.storeAddress, title: item.title)
            
            getData()
            bind()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .default))
        present(alert, animated: true)
    }
}


// MARK: - ReviewCell protocol
protocol ReviewCellDelegate: AnyObject {
    func editReview(_ review: ReviewModel, indexPath: IndexPath)
    func deleteReview(_ review: ReviewModel, indexPath: IndexPath)
}
