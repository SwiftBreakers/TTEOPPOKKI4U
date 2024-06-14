//
//  ManageViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/12/24.
//

import UIKit
import SnapKit
import Combine

class ManageViewController: UIViewController {
    
    private let manageView = ManageView()
    
    var viewModel: ManageViewModel!
    
    private var tableDatasource: UITableViewDiffableDataSource<DiffableSectionModel, DiffableSectionItemModel>?
    private var cancellables = Set<AnyCancellable>()
    
    convenience init(viewModel: ManageViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        layout()
        viewModel.getUsers()
        configureDiffableDataSource()
        
        manageView.segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bind()
        configureDiffableDataSource()
    }
    
    
    private func bind() {
        viewModel.$userReview
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureReviewSnapshot()
            }.store(in: &cancellables)
        viewModel.$userArray
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureUserSnapshot()
            }.store(in: &cancellables)
    }
    
    private func layout() {
        view.addSubview(manageView)
        
        manageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.getUsers()
        case 1:
            viewModel.getReviews()
        default :
            return
        }
    }
}

// MARK: - Diffable DataSource
extension ManageViewController {
    func configureDiffableDataSource() {
        tableDatasource = UITableViewDiffableDataSource(tableView: manageView.tableView, cellProvider: { [self] tableView, indexPath, itemIdentifier in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManageTableViewCell", for: indexPath) as! ManageTableViewCell
            
            switch itemIdentifier {
            case .user(let users):
                
                cell.titleLabel.text = users.uid
                
                cell.deactivateTapped = { [weak viewModel, weak self] in
                    viewModel?.deactivateUser(uid: users.uid, completion: {
                        self?.showMessage(title: "처리완료", message: "Block처리 되었습니다")
                    })
                    
                }
                cell.activateTapped = { [weak viewModel, weak self] in
                    viewModel?.activateUser(uid: users.uid, completion: {
                        self?.showMessage(title: "처리완료", message: "Block해제 되었습니다")
                    })
                }
                return cell
                
            case .review(let review):
                
                cell.titleLabel.text = review.title
                cell.activateTapped = { [weak viewModel, weak self] in
                    viewModel?.activateReview(uid: review.uid, storeAddress: review.storeAddress, title: review.title, completion: {
                        self?.showMessage(title: "처리완료", message: "Block해제 되었습니다")
                    })
                }
                cell.deactivateTapped = {  [weak viewModel, weak self] in
                    viewModel?.deactivateReview(uid: review.uid, storeAddress: review.storeAddress, title: review.title, completion: {
                        self?.showMessage(title: "처리완료", message: "Block처리 되었습니다")
                    })
                }
                
                return cell
            }
            
        })
    }
    
    func configureUserSnapshot() {
        var userSnapshot = NSDiffableDataSourceSnapshot<DiffableSectionModel, DiffableSectionItemModel>()
        
        userSnapshot.appendSections([.user])
        let userItems = viewModel.userArray.map { DiffableSectionItemModel.user($0) }
        userSnapshot.appendItems(userItems, toSection: .user)
        
        tableDatasource?.apply(userSnapshot, animatingDifferences: true)
    }
    
    func configureReviewSnapshot() {
        var reviewSnapshot = NSDiffableDataSourceSnapshot<DiffableSectionModel, DiffableSectionItemModel>()
        
        reviewSnapshot.appendSections([.review])
        let reviewItems = viewModel.userReview.map { DiffableSectionItemModel.review($0) }
        reviewSnapshot.appendItems(reviewItems, toSection: .review)
        
        tableDatasource?.apply(reviewSnapshot, animatingDifferences: true)
    }
    
}
