//
//  MyReviewViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/30/24.
//
import UIKit
import SnapKit

class MyReviewViewController: UIViewController {

    private var reviews: [Review] = [
        Review(id: 1, title: "Great product!", rating: 4.5, content: "I really enjoyed using this product. It exceeded my expectations in every way."),
        Review(id: 2, title: "Not bad", rating: 3.0, content: "The product is okay, but it has some flaws that need to be addressed."),
        Review(id: 3, title: "Terrible experience", rating: 1.0, content: "I had a very bad experience with this product. It did not work as advertised and the customer service was unhelpful.")
    ]
    
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

    private lazy var registerButton: UIButton = {
           let button = UIButton(type: .system)
           button.setTitle("등록하기", for: .normal)
        button.titleLabel?.font = UIFont.init(name: ThemeFont.fontMedium, size: 17)
           button.addTarget(self, action: #selector(addReview), for: .touchUpInside)
           return button
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchReviews()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(backButton)
        view.addSubview(registerButton)
        
        backButton.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        registerButton.snp.makeConstraints { make in
                    make.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
                }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
     
    }
    
    private func fetchReviews() {
        // Fetch reviews from your data source and reload collectionView
        // reviews = fetchData()
        collectionView.reloadData()
    }
    
    @objc private func addReview() {
     //   let addReviewVC = AddEditReviewViewController()
       // addReviewVC.delegate = self
        //navigationController?.pushViewController(addReviewVC, animated: true)
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: - UICollectionView Datasource and Delegate Methods
extension MyReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.identifier, for: indexPath) as! ReviewCell
        cell.configure(with: reviews[indexPath.item])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200)
    }
}

extension MyReviewViewController: ReviewCellDelegate {
    func editReview(_ review: Review) {
  //      let editReviewVC = AddEditReviewViewController()
    //    editReviewVC.review = review
     //   editReviewVC.delegate = self
      //  navigationController?.pushViewController(editReviewVC, animated: true)
    }
    
    func deleteReview(_ review: Review) {
        if let index = reviews.firstIndex(where: { $0.id == review.id }) {
            reviews.remove(at: index)
            collectionView.reloadData()
        }
    }
}

extension MyReviewViewController: AddEditReviewViewControllerDelegate {
    func didSaveReview(_ review: Review) {
        if let index = reviews.firstIndex(where: { $0.id == review.id }) {
            reviews[index] = review
        } else {
            reviews.append(review)
        }
        collectionView.reloadData()
    }
}


// MARK: - ReviewCell edit and delete protocol
protocol ReviewCellDelegate: AnyObject {
    func editReview(_ review: Review)
    func deleteReview(_ review: Review)
}

protocol AddEditReviewViewControllerDelegate: AnyObject {
    func didSaveReview(_ review: Review)
}

//class AddEditReviewViewController: UIViewController {
//    
//    var review: Review?
//    weak var delegate: AddEditReviewViewControllerDelegate?
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Title"
//        return label
//    }()
//    
//    private let titleTextField: UITextField = {
//        let textField = UITextField()
//        textField.borderStyle = .roundedRect
//        return textField
//    }()
//    
//    private let ratingLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Rating"
//        return label
//    }()
//    
//    private let ratingTextField: UITextField = {
//        let textField = UITextField()
//        textField.borderStyle = .roundedRect
//        return textField
//    }()
//    
//    private let contentLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Content"
//        return label
//    }()
//    
//    private let contentTextField: UITextField = {
//        let textField = UITextField()
//        textField.borderStyle = .roundedRect
//        return textField
//    }()
//    
//    private let saveButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Save", for: .normal)
//        // button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //setupViews
//    }
//}
