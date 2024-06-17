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
    
    var storeName: String?
    var reviewTitle: String?
    var starRating: Int?
    var reviewContent: String?
    var reviewImages: [String]?
    
    private lazy var storeNameLabel = UILabel()
    private lazy var reviewTitleLabel = UILabel()
    private lazy var starRatingLabel = UILabel()
    private lazy var reviewContentLabel = UILabel()
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
        
        storeNameLabel.font = ThemeFont.fontMedium(size: 24)
        storeNameLabel.textAlignment = .center
        view.addSubview(storeNameLabel)
        
        reviewTitleLabel.font = ThemeFont.fontMedium(size: 20)
        reviewTitleLabel.textAlignment = .center
        view.addSubview(reviewTitleLabel)
        
        starRatingLabel.font = ThemeFont.fontRegular()
        starRatingLabel.textAlignment = .center
        view.addSubview(starRatingLabel)
        
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        scrollView.addSubview(stackView)
        
        reviewContentLabel.font = ThemeFont.fontRegular()
        reviewContentLabel.numberOfLines = 0
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
        
        configureUI()
        configureImageScrollView()
    }
    
    private func configureUI() {
        storeNameLabel.text = storeName
        reviewTitleLabel.text = reviewTitle
        starRatingLabel.text = "⭐️ \(starRating ?? 0)"
        reviewContentLabel.text = reviewContent
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
        let alert = UIAlertController(title: "신고", message: "이 리뷰를 신고하시겠습니까?", preferredStyle: .alert)
        
        // 텍스트 필드 추가
        alert.addTextField { textField in
            textField.placeholder = "신고 사유를 입력해 주세요"
        }
        
        alert.addAction(UIAlertAction(title: "예", style: .default, handler: { _ in
            if let reason = alert.textFields?.first?.text {
                print("신고 사유: \(reason)")
            }
            self.showMessage(title: "신고", message: "리뷰가 신고되었습니다.")
        }))
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
