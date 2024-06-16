//
//  StoreViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/5/24.
//

import UIKit
import SnapKit
import Combine

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
    private let storeImages = ["tpkImage1", "tpkImage1WithBg"]
    private let storeLocation = "123길 123"
    //private let reviews = [ReviewModel]()
    
    let viewModel = ReviewViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        configureUI()
        locationLabel.text = addressText
        storeNameLabel.text = shopTitleText
       
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRequest()
        bind()
    }
    
    private func fetchRequest() {
        viewModel.getStoreReview(storeAddress: addressText!)
    }
    
    private func bind() {
        viewModel.$userReview
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.tableView.reloadData()
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
        view.backgroundColor = .white
        
        // Setup Back Button
        
        let image = UIImage(systemName: "chevron.backward.2")
        backButton.setImage(image, for: .normal)
        backButton.tintColor = .systemGray
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        // Setup Title Label
        storeNameLabel.text = storeName
        storeNameLabel.font = ThemeFont.fontMedium(size: 24)
        storeNameLabel.textAlignment = .center
        view.addSubview(storeNameLabel)
        
        // Setup Scroll View and Stack View
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
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
        locationLabel.font = ThemeFont.fontRegular(size: 17)
        locationLabel.textAlignment = .center
        view.addSubview(locationLabel)
        
        // Setup Review Button
        goReviewButton.setTitle("리뷰 작성하기", for: .normal)
        goReviewButton.titleLabel?.font = ThemeFont.fontBold(size: 18)
        goReviewButton.setTitleColor(.white, for: .normal)
        goReviewButton.backgroundColor = ThemeColor.mainOrange
        goReviewButton.layer.cornerRadius = 10
    
        view.addSubview(goReviewButton)
        goReviewButton.addTarget(self, action: #selector(goReviewButtonTapped), for: .touchUpInside)
        
        // Setup Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: "ReviewTableViewCell")
        tableView.rowHeight = 50
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
            make.top.equalTo(backButton.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.snp.width).multipliedBy(0.8 * 0.75) // 4:3 aspect ratio of the image views
        }
        
        // Stack View Constraints
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Location Label Constraints
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Table View Constraints
        tableView.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(40)
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
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goReviewButtonTapped() {
        let writeVC = WriteViewController()
        writeVC.addressText = addressText
        writeVC.storeTitleText = shopTitleText
        navigationController?.pushViewController(writeVC, animated: true)
    }
    
}

extension StoreViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userReview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as! ReviewTableViewCell
        let item = viewModel.userReview[indexPath.row]
        cell.reviewTitleLabel.text = item.title
        cell.starRatingLabel.text = "⭐️ \(item.rating)"
        return cell
    }
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = viewModel.userReview[indexPath.row]
        let detailedReviewVC = DetailedReviewViewController()
        detailedReviewVC.storeName = item.storeName
        detailedReviewVC.reviewTitle = item.title
        detailedReviewVC.starRating = Int(item.rating)
        detailedReviewVC.reviewContent = item.content
        detailedReviewVC.reviewImages = item.imageURL
        navigationController?.pushViewController(detailedReviewVC, animated: true)
    }
    
}

