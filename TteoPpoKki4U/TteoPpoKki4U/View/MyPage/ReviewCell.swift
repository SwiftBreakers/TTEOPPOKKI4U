//
//  ReviewCell.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/31/24.
//

import UIKit

class ReviewCell: UICollectionViewCell {
    
    static let identifier = "ReviewCell"
    var delegate: ReviewCellDelegate?
    private var review: Review?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정", for: .normal)
        button.titleLabel?.font = UIFont(name: ThemeFont.fontMedium, size: 17)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제", for: .normal)
        button.titleLabel?.font = UIFont(name: ThemeFont.fontMedium, size: 17)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(deleteButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(264)  // 200픽셀 오른쪽으로 이동
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.leading.equalTo(editButton.snp.trailing).offset(20)
        }
        
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    func configure(with review: Review) {
        self.review = review
        titleLabel.text = review.title
        ratingLabel.text = "Rating: \(review.rating)"
        contentLabel.text = review.content
    }
    
    @objc private func editTapped() {
        if let review = review {
            delegate?.editReview(review)
        }
    }
    
    @objc private func deleteTapped() {
        if let review = review {
            delegate?.deleteReview(review)
        }
    }
}
