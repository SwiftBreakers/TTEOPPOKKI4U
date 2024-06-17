import UIKit

class ReviewCell: UICollectionViewCell {
    
    static let identifier = "ReviewCell"
    var delegate: ReviewCellDelegate?
    private var review: ReviewModel?
    private var indexPath: IndexPath? // indexPath 추가
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontBold(size: 17)
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 14)
        label.textColor = .gray
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = ThemeColor.mainGreen
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.app.fill"), for: .normal)
        button.tintColor = .gray
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
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
//        editButton.snp.makeConstraints { make in
//            make.top.equalTo(contentLabel.snp.bottom).offset(8)
//            make.trailing.equalTo(deleteButton.snp.leading).offset(-20)
//        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.width.height.equalTo(28)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.width.height.equalTo(28)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-20)
        }
        
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    func configure(with review: ReviewModel, indexPath: IndexPath) {
        self.review = review
        self.indexPath = indexPath // indexPath 설정
        titleLabel.text = review.title
        ratingLabel.text = "Rating: \(review.rating)"
        contentLabel.text = review.content
    }
    
    @objc private func editTapped() {
        if let review = review, let indexPath = indexPath {
            delegate?.editReview(review, indexPath: indexPath)
        }
    }
    
    @objc private func deleteTapped() {
        if let review = review, let indexPath = indexPath {
            delegate?.deleteReview(review, indexPath: indexPath)
        }
    }
}
