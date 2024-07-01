import UIKit

class ReviewCell: UICollectionViewCell {
    
    static let identifier = "ReviewCell"
    var delegate: ReviewCellDelegate?
    private var review: ReviewModel?
    private var indexPath: IndexPath? // indexPath 추가
    
    private let storeLabel: UILabel = {
            let label = UILabel()
            label.font = ThemeFont.fontBold(size: 20)
        label.textColor = ThemeColor.mainBlack
            label.text = "가게이름"
            return label
        }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 17)
        label.textColor = ThemeColor.mainBlack
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
        label.textColor = ThemeColor.mainBlack
        label.numberOfLines = 1
        return label
    }()

    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정", for: .normal)
        button.titleLabel?.font = ThemeFont.fontMedium(size: 14)
        button.titleLabel?.textColor = .white
        button.backgroundColor = ThemeColor.mainOrange
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제", for: .normal)
        button.titleLabel?.font = ThemeFont.fontMedium(size: 14)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [UIView(), buttonStackView])
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [editButton, deleteButton])
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        self.backgroundColor = .white
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(storeLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(contentLabel)
//        contentView.addSubview(editButton)
//        contentView.addSubview(deleteButton)
        contentView.addSubview(hStackView)
        
        storeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
                   make.leading.trailing.equalToSuperview().inset(20)
               }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(storeLabel.snp.bottom).offset(10)
                       make.leading.trailing.equalToSuperview().inset(20)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
//        editButton.snp.makeConstraints { make in
//            make.top.equalTo(contentLabel.snp.bottom).offset(8)
//            make.trailing.equalTo(deleteButton.snp.leading).offset(-20)
//        }
        
//        editButton.snp.makeConstraints { make in
//            make.top.equalTo(contentLabel.snp.bottom).offset(8)
//            make.leading.equalToSuperview().offset(200)
//            make.bottom.equalToSuperview().offset(-10)
//        }
//        
//        deleteButton.snp.makeConstraints { make in
//            make.top.equalTo(contentLabel.snp.bottom).offset(8)
//            make.leading.equalTo(editButton.snp.trailing).offset(8)
//            make.trailing.equalToSuperview().offset(-20)
//            make.bottom.equalToSuperview().offset(-10)
//        }
        
        hStackView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    func configure(with review: ReviewModel, indexPath: IndexPath) {
        self.review = review
        self.indexPath = indexPath // indexPath 설정
        storeLabel.text = review.storeName
        titleLabel.text = review.title
        ratingLabel.text = "⭐️ \(review.rating)"
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
