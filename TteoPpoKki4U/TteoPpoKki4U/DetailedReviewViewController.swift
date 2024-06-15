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
    private lazy var imageViews = [UIImageView]()
    private lazy var reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("신고", for: .normal)
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
        
        view.addSubview(reportButton)
        view.addSubview(backButton)
        storeNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        reportButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
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
            //let reportVC = ReportViewController()
            //self.present(reportVC, animated: true)
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
