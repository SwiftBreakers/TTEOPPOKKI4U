//
//  StoreViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/5/24.
//

import UIKit
import SnapKit

class StoreViewController: UIViewController {
    
    // UI Components
    private let backButton = UIButton()
    private let storeNameLabel = UILabel()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let locationLabel = UILabel()
    private let goReviewButton = UIButton()
    private let tableView = UITableView()
    
    var addressText: String?
    var shopTitleText: String?
    // Dummy data
       private let storeName = "울랄라 떡볶이"
       private let storeImages = ["image1", "image2", "image3"]
       private let storeLocation = "123길 123"
       private let reviews = [
           ("Amazing Tteokbokki!", 5),
           ("Good, but could be spicier", 4),
           ("Just okay", 3)
       ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        configureUI()
        locationLabel.text = addressText
        storeNameLabel.text = shopTitleText
        fetchRequest()
    }
    
    private func fetchRequest() {
        
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // Setup Back Button
       
        let image = UIImage(systemName: "chevron.backward.2")
        backButton.setImage(image, for: .normal)
        backButton.tintColor = .systemGray
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        // Setup Title Label
        storeNameLabel.text = storeName
        storeNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        storeNameLabel.textAlignment = .center
        view.addSubview(storeNameLabel)
        
        // Setup Scroll View and Stack View
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        stackView.axis = .horizontal
        stackView.spacing = 10
        scrollView.addSubview(stackView)
        
        // Add images to stack view
        for imageName in storeImages {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            stackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalTo(view.snp.width).multipliedBy(0.8)
                make.height.equalTo(imageView.snp.width).multipliedBy(0.75) // 4:3 aspect ratio
            }
        }
        
        // Setup Location Label
        locationLabel.text = storeLocation
        locationLabel.textAlignment = .center
        view.addSubview(locationLabel)
        
        // Setup Review Button
        goReviewButton.setTitle("리뷰 작성하기", for: .normal)
        goReviewButton.setTitleColor(.white, for: .normal)
        goReviewButton.backgroundColor = .systemBlue
        goReviewButton.layer.cornerRadius = 10
        goReviewButton.addTarget(self, action: #selector(reviewButtonDidTapped), for: .touchUpInside)
        view.addSubview(goReviewButton)
        
        // Setup Table View
                tableView.delegate = self
                tableView.dataSource = self
                tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: "reviewCell")
                view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        // Back Button Constraints
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        // Title Label Constraints
        storeNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        // Scroll View Constraints
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.snp.width).multipliedBy(0.8 * 0.75) // 4:3 aspect ratio of the image views
        }
        
        // Stack View Constraints
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.height.equalToSuperview()
        }
        
        // Location Label Constraints
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Table View Constraints
              tableView.snp.makeConstraints { make in
                  make.top.equalTo(locationLabel.snp.bottom).offset(20)
                  make.leading.trailing.equalToSuperview()
                  make.bottom.equalTo(goReviewButton.snp.top).offset(-20)
              }
        
        // Review Button Constraints
        goReviewButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
    }
    
    private func configureUI() {
        // Additional UI configuration if needed
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func reviewButtonDidTapped() {
        let writeVC = WriteViewController()
        writeVC.addressText = addressText
        writeVC.storeTitleText = shopTitleText
        present(writeVC, animated: true)
    }
    
}

extension StoreViewController: UITableViewDelegate, UITableViewDataSource {
   // MARK: - UITableViewDataSource Methods
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return reviews.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
          let review = reviews[indexPath.row]
          cell.reviewTitleLabel.text = review.0
          cell.starRatingLabel.text = "⭐️ \(review.1)"
          return cell
      }
      // MARK: - UITableViewDelegate Methods
    
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           
           let review = reviews[indexPath.row]
           let detailedReviewVC = DetailedReviewViewController()
           detailedReviewVC.storeName = storeName
           detailedReviewVC.reviewTitle = review.0
           detailedReviewVC.starRating = review.1
           detailedReviewVC.reviewContent = "This is a detailed review content for \(review.0)."
           present(detailedReviewVC, animated: true)
       }
}

