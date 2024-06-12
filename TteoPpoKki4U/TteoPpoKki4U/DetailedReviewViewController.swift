//
//  DetailedReviewViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/5/24.
//

import UIKit

class DetailedReviewViewController: UIViewController {

    var storeName: String?
       var reviewTitle: String?
       var starRating: Int?
       var reviewContent: String?
       
       private let storeNameLabel = UILabel()
       private let reviewTitleLabel = UILabel()
       private let starRatingLabel = UILabel()
       private let reviewContentLabel = UILabel()
       
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
           
           reviewContentLabel.font = ThemeFont.fontRegular()
           reviewContentLabel.numberOfLines = 0
           view.addSubview(reviewContentLabel)
           
           storeNameLabel.snp.makeConstraints { make in
               make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
               make.leading.trailing.equalToSuperview().inset(20)
           }
           
           reviewTitleLabel.snp.makeConstraints { make in
               make.top.equalTo(storeNameLabel.snp.bottom).offset(20)
               make.leading.trailing.equalToSuperview().inset(20)
           }
           
           starRatingLabel.snp.makeConstraints { make in
               make.top.equalTo(reviewTitleLabel.snp.bottom).offset(20)
               make.leading.trailing.equalToSuperview().inset(20)
           }
           
           reviewContentLabel.snp.makeConstraints { make in
               make.top.equalTo(starRatingLabel.snp.bottom).offset(20)
               make.leading.trailing.equalToSuperview().inset(20)
           }
           
           configureUI()
       }
       
       private func configureUI() {
           storeNameLabel.text = storeName
           reviewTitleLabel.text = reviewTitle
           starRatingLabel.text = "⭐️ \(starRating ?? 0)"
           reviewContentLabel.text = reviewContent
       }

}
