//
//  StoreViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/7/24.
//

import UIKit
import Kingfisher
import SnapKit

class DetailedReviewViewController: UIViewController {
    
    var userData: ReviewModel?
    private var storeName: String?
    private var reviewTitle: String?
    private var starRating: Int?
    private var reviewContent: String?
    private var reviewImages: [String]?
    private var uid: String?
    private var reportCount: Int?
    
    private lazy var storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 24)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private lazy var reviewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 20)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private lazy var starRatingLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular()
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private lazy var reviewContentLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular()
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private lazy var scrollView = UIScrollView()
    private lazy var stackView = UIStackView()
    private lazy var imageView = UIImageView()
    private lazy var reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("신고", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = ThemeFont.fontMedium(size: 16)
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.backward.2"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setData(data: userData!)
        configureUI()
        configureImageScrollView()
    }
    
    deinit {
        print("DetailedReviewViewController is being deinitialized")
        
        userData = nil
        storeName = nil
        reviewTitle = nil
        starRating = nil
        reviewContent = nil
        reviewImages = nil
        uid = nil
        reportCount = nil
        
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        
        scrollView.removeFromSuperview()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.removeFromSuperview()
    }
    
    private func setData(data: ReviewModel) {
        storeName = data.storeName
        reviewTitle = data.title
        starRating = Int(data.rating)
        reviewContent = data.content
        reviewImages = data.imageURL
        uid = data.uid
        reportCount = data.reportCount
    }
    
    private func configureUI() {
        storeNameLabel.text = storeName
        reviewTitleLabel.text = reviewTitle
        starRatingLabel.text = "⭐️ \(starRating ?? 0)"
        reviewContentLabel.text = reviewContent
        
        
        view.addSubview(storeNameLabel)
        
        
        view.addSubview(reviewTitleLabel)
        
        
        view.addSubview(starRatingLabel)
        
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        scrollView.addSubview(stackView)
        
        
        view.addSubview(reviewContentLabel)
        
        view.addSubview(reportButton)
        view.addSubview(backButton)
        
        storeNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
        }
        
        reportButton.snp.makeConstraints { make in
            make.centerY.equalTo(storeNameLabel)
            make.trailing.equalToSuperview().inset(20)
        }
        
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(storeNameLabel)
            make.leading.equalToSuperview().offset(20)
        }
        
        reviewTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        starRatingLabel.snp.makeConstraints { make in
            make.top.equalTo(reviewTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        reviewContentLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
    }
    
    private func configureImageScrollView() {
        guard let imageURLs = reviewImages else { return }
        
        if imageURLs.count == 1, let imageURL = imageURLs.first {
            scrollView.removeFromSuperview()
            view.addSubview(imageView)
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageView.kf.setImage(with: URL(string: imageURL))
            
            imageView.snp.makeConstraints { make in
                make.top.equalTo(starRatingLabel.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(20)  // 스크롤뷰와 동일한 사이즈
                make.height.equalTo(imageView.snp.width).multipliedBy(0.75)
            }
            
            reviewContentLabel.snp.remakeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(20)
            }
        } else {
            view.addSubview(scrollView)
            
            scrollView.snp.remakeConstraints { make in
                make.top.equalTo(starRatingLabel.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(200)
            }
            
            stackView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(scrollView.snp.height)
            }
            
            addImagesToStackView(imageURLs)
        }
    }
    
    private func addImagesToStackView(_ imageURLs: [String]) {
        for imageView in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
        }
        
        for imageURL in imageURLs {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageView.kf.setImage(with: URL(string: imageURL))
            stackView.addArrangedSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.width.equalTo(scrollView.snp.width).multipliedBy(0.8)
                make.height.equalTo(imageView.snp.width).multipliedBy(0.75)
            }
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func reportButtonTapped() {
        showMessageWithCancel(title: "신고하기", message: "해당 리뷰를 신고하시겠습니까?") { [weak self]  in
            let reportVC = ReportViewController()
            reportVC.userData = self?.userData
            self?.present(reportVC, animated: true)
        }
    }
    
    private func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
