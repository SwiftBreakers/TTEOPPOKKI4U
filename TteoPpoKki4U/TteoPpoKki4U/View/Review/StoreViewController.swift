//
//  StoreViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/5/24.
//

import UIKit
import SnapKit
import Combine
import FirebaseAuth

class StoreViewController: UIViewController {
    
    // UI Components
    private let backButton = UIButton()
    private let storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontBold(size: 24)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    private let goReviewButton = UIButton()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: "ReviewTableViewCell")
        tableView.rowHeight = 50
        tableView.backgroundColor = .white
        return tableView
    }()
    private let seperateView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    private let reviewCountLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium()
        return label
    }()
    
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
            .sink { array in
                self.reviewCountLabel.text = "리뷰 \(array.count)개"
                if array.count == 0 {
                    self.tableView.setEmptyMsg("아직 작성한 리뷰가 없어요!\n첫 리뷰를 작성해 주세요.")
                    self.tableView.reloadData()
                } else {
                    self.tableView.restore()
                    self.tableView.reloadData()
                }
                
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
        
        // Setup Title Label
        storeNameLabel.text = storeName
        view.addSubview(storeNameLabel)
        
        // Setup Scroll View and Stack View
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .white
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
        view.addSubview(locationLabel)
        
        // Setup Review Button
        goReviewButton.setTitle("리뷰 작성하기", for: .normal)
        goReviewButton.titleLabel?.font = ThemeFont.fontBold(size: 18)
        goReviewButton.setTitleColor(.white, for: .normal)
        goReviewButton.backgroundColor = ThemeColor.mainOrange
        goReviewButton.layer.cornerRadius = 10
        
        view.addSubview(goReviewButton)
        goReviewButton.addTarget(self, action: #selector(goReviewButtonTapped), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        // Setup Back Button
        let image = UIImage(systemName: "chevron.backward.2")
        backButton.setImage(image, for: .normal)
        backButton.tintColor = .gray
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        view.addSubview(seperateView)
        view.addSubview(reviewCountLabel)
    }
    
    private func setupConstraints() {

        
        // Title Label Constraints
        storeNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(scrollView.snp.bottom).offset(20)
        }
        
        // Scroll View Constraints
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.snp.width).multipliedBy(0.8 * 0.75) // 4:3 aspect ratio of the image views
        }
        
        // Stack View Constraints
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Location Label Constraints
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        seperateView.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(60)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(6)
        }
        
        reviewCountLabel.snp.makeConstraints { make in
            make.top.equalTo(seperateView.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        // Table View Constraints
        tableView.snp.makeConstraints { make in
            make.top.equalTo(reviewCountLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(goReviewButton.snp.top).offset(-10)
        }
        
        // Review Button Constraints
        goReviewButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
        
        // Back Button Constraints
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
    }
    
    private func configureUI() {
        // Additional UI configuration if needed
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goReviewButtonTapped() {
        if let _ = Auth.auth().currentUser?.uid {
            let writeVC = WriteViewController()
            writeVC.addressText = addressText
            writeVC.storeTitleText = shopTitleText
            navigationController?.pushViewController(writeVC, animated: true)
        } else {
            showMessage(title: "안내", message: "로그인이 필요한 기능입니다.")
        }
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
        detailedReviewVC.userData = item
        navigationController?.pushViewController(detailedReviewVC, animated: true)
    }
    
}

