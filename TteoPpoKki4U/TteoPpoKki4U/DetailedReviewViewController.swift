//
//  DetailedReviewViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/5/24.
//

import UIKit
import Kingfisher

class DetailedReviewViewController: UIViewController {
    
    var storeName: String?
    var reviewTitle: String?
    var starRating: Int?
    var reviewContent: String?
    var reviewImages: [String]?
    
    private let storeNameLabel = UILabel()
    private let reviewTitleLabel = UILabel()
    private let starRatingLabel = UILabel()
    private let reviewContentLabel = UILabel()
    private let scrollView = UIScrollView()
    private var imageViews = [UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
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
        
        reviewContentLabel.font = ThemeFont.fontRegular()
        reviewContentLabel.numberOfLines = 0
        view.addSubview(reviewContentLabel)
        
        storeNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        reviewTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        starRatingLabel.snp.makeConstraints { make in
            make.top.equalTo(reviewTitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(starRatingLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(260)
        }
        
        reviewContentLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        configureImageScrollView()
        configureUI()
    }
    
    private func configureUI() {
        storeNameLabel.text = storeName
        reviewTitleLabel.text = reviewTitle
        starRatingLabel.text = "⭐️ \(starRating ?? 0)"
        reviewContentLabel.text = reviewContent
    }
    
    private func configureImageScrollView() {
        var images = [UIImage]()
        
        if let imageURLs = reviewImages {
            let dispatchGroup = DispatchGroup()
            
            for imageURL in imageURLs {
                dispatchGroup.enter()
                KingfisherManager.shared.retrieveImage(with: URL(string: imageURL)!) { [weak self] result in
                    switch result {
                    case .success(let image):
                        images.append(image.image)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self?.showMessage(title: "이미지 로딩 오류", message: "\(error.localizedDescription)이 발생하였습니다.")
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.addImagesToScrollView(images)
            }
        } else {
            images = [UIImage(named: "tpkImage1"), UIImage(named: "tpkImage1WithBg")].compactMap { $0 }
            addImagesToScrollView(images)
        }
    }

    private func addImagesToScrollView(_ images: [UIImage]) {
        var previousImageView: UIImageView?
        
        for image in images {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            scrollView.addSubview(imageView)
            imageViews.append(imageView)
            
            imageView.snp.makeConstraints { make in
                make.width.equalTo(view.snp.width).multipliedBy(0.8)
                make.height.equalTo(imageView.snp.width).multipliedBy(0.75)
                
                if let previous = previousImageView {
                    make.leading.equalTo(previous.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            
            previousImageView = imageView
        }
        
        if let lastImageView = imageViews.last {
            lastImageView.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
            }
        }
    }

}
