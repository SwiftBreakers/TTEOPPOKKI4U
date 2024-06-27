//
//  StoreViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/7/24.
//

import UIKit
import Kingfisher
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class DetailedReviewViewController: UIViewController {
    
    var userData: ReviewModel?
    var userInfo: UserModel?
    private var storeName: String?
    private var reviewTitle: String?
    private var starRating: Int?
    private var reviewContent: String?
    private var reviewImages: [String]?
    private var uid: String?
    private var reportCount: Int?
    private var createdAt: String?
    private var userProfile: String?
    private var userNickname: String?
    
    private lazy var groundScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        view.backgroundColor = .white
        return view
    }()
    private lazy var contentView = UIView()
    private lazy var storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontBold(size: 24)
        label.textAlignment = .center
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    private lazy var reviewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 22)
        label.textAlignment = .left
        label.textColor = ThemeColor.mainBlack
        label.numberOfLines = 0
        return label
    }()
    private lazy var userProfileImage: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        return view
    }()
    private lazy var userNicknameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 16)
        label.textColor = ThemeColor.mainBlack
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    private lazy var starRatingLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 14)
        label.textAlignment = .left
        label.textColor = ThemeColor.mainBlack
        label.sizeToFit()
        return label
    }()
    private lazy var createdAtLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 14)
        label.textColor = .gray
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    private lazy var reviewContentLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular()
        label.textColor = ThemeColor.mainBlack
        label.numberOfLines = 0
        label.setLineSpacing(lineSpacing: 5)
        return label
    }()
    
    private lazy var scrollView = UIScrollView()
    private lazy var stackView = UIStackView()
    private lazy var imageView = UIImageView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setTabAndNavi()
        setData(data: userData!)
        setUserData(info: userInfo!)
        configureUI()
        configureImageScrollView()
    }
    
    deinit {
        userData = nil
        storeName = nil
        reviewTitle = nil
        starRating = nil
        reviewContent = nil
        reviewImages = nil
        uid = nil
        reportCount = nil
        createdAt = nil
        userInfo = nil
        userProfile = nil
        userNickname = nil
        
        userProfileImage.kf.cancelDownloadTask()
        userProfileImage.image = nil
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        
        scrollView.removeFromSuperview()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.removeFromSuperview()
    }
    
    private func setTabAndNavi() {
        tabBarController?.tabBar.isHidden = true
        
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .white
        UINavigationBar.appearance().barTintColor = .white
        navigationController?.navigationBar.tintColor = ThemeColor.mainOrange
        navigationItem.title = "리뷰 전체보기"
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ThemeColor.mainBlack]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "신고", style: .plain, target: self, action: #selector(reportButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .red
    }
    
    private func setData(data: ReviewModel) {
        storeName = data.storeName
        reviewTitle = data.title
        starRating = Int(data.rating)
        reviewContent = data.content
        reviewImages = data.imageURL
        uid = data.uid
        reportCount = data.reportCount
        createdAt = timestampToString(value: data.createdAt)
    }
    
    private func setUserData(info: UserModel) {
        userProfile = info.profileImageUrl
        userNickname = info.nickName
    }
    
    private func configureUI() {
        storeNameLabel.text = storeName
        reviewTitleLabel.text = reviewTitle
        userProfileImage.kf.setImage(with: URL(string: userProfile ?? ""), placeholder: UIImage(named: "ttukbokki4u1n"))
        userNicknameLabel.text = userNickname
        starRatingLabel.text = "⭐️ \(starRating ?? 0)"
        reviewContentLabel.text = reviewContent
        createdAtLabel.text = createdAt
        
        view.addSubview(storeNameLabel)
        
        groundScrollView.addSubview(contentView)
        [scrollView, reviewTitleLabel, userProfileImage, userNicknameLabel, starRatingLabel, createdAtLabel, reviewContentLabel].forEach {
            contentView.addSubview($0)
        }
        view.addSubview(groundScrollView)
        
        scrollView.isPagingEnabled = true
        
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        scrollView.addSubview(stackView)
        
        storeNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
        }
        
        groundScrollView.snp.makeConstraints { make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(groundScrollView)
            make.width.equalTo(groundScrollView)
        }
        
        reviewTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        userProfileImage.snp.makeConstraints { make in
            make.top.equalTo(reviewTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(44)
        }
        
        userNicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(userProfileImage.snp.top)
            make.leading.equalTo(userProfileImage.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }
        
        starRatingLabel.snp.makeConstraints { make in
            make.leading.equalTo(userProfileImage.snp.trailing).offset(10)
            make.bottom.equalTo(userProfileImage.snp.bottom)
        }
        
        createdAtLabel.snp.makeConstraints { make in
            make.leading.equalTo(starRatingLabel.snp.trailing).offset(10)
            make.centerY.equalTo(starRatingLabel)
        }
        
        reviewContentLabel.snp.makeConstraints { make in
            make.top.equalTo(starRatingLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    
    private func configureImageScrollView() {
        guard let imageURLs = reviewImages else { return }
        
        if imageURLs.count == 0 {
            scrollView.removeFromSuperview()
            reviewTitleLabel.snp.remakeConstraints { make in
                make.top.equalTo(storeNameLabel.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(20)
            }
        } else if imageURLs.count == 1, let imageURLString = imageURLs.first, let imageURL = URL(string: imageURLString) {
            scrollView.removeFromSuperview()
            contentView.addSubview(imageView)
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imageView.addGestureRecognizer(tap)
            imageView.kf.setImage(with: imageURL) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.imageView.imageURL = value.source.url
                case .failure:
                    self?.imageView.imageURL = nil
                }
            }
            
            imageView.snp.makeConstraints { make in
                make.top.equalTo(storeNameLabel.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(20)  // 스크롤뷰와 동일한 사이즈
                make.height.equalTo(imageView.snp.width).multipliedBy(0.75)
            }
            
            reviewTitleLabel.snp.remakeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview().inset(20)
            }
        } else {
            contentView.addSubview(scrollView)
            
            scrollView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(20)
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

        for imageURLString in imageURLs {
            guard let imageURL = URL(string: imageURLString) else { continue }
            
            let imageView = UIImageView()
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageView.isUserInteractionEnabled = true
            
            imageView.kf.setImage(with: imageURL) { result in
                switch result {
                case .success(let value):
                    imageView.imageURL = value.source.url
                case .failure:
                    imageView.imageURL = nil
                }
            }
            
            imageView.addGestureRecognizer(tap)
            stackView.addArrangedSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.width.equalTo(scrollView.snp.width).multipliedBy(0.8)
                make.height.equalTo(imageView.snp.width).multipliedBy(0.75)
            }
        }
    }

    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView,
              let tappedImageURL = tappedImageView.imageURL,
              let reviewImages = reviewImages else { return }
        
        let imageURLs = reviewImages.compactMap { URL(string: $0) }
        
        if let currentIndex = imageURLs.firstIndex(of: tappedImageURL) {
            let fullscreenPageVC = FullscreenPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            fullscreenPageVC.modalPresentationStyle = .fullScreen
            fullscreenPageVC.imageURLs = imageURLs
            fullscreenPageVC.currentIndex = currentIndex
            
            self.present(fullscreenPageVC, animated: true, completion: nil)
        }
    }
    
    @objc private func reportButtonTapped() {
        if let _ = Auth.auth().currentUser?.uid {
            showMessageWithCancel(title: "신고하기", message: "해당 리뷰를 신고하시겠습니까?") { [weak self]  in
                let reportVC = ReportViewController()
                reportVC.userData = self?.userData
                self?.present(reportVC, animated: true)
            }
        } else {
            showMessage(title: "안내", message: "로그인이 필요한 기능입니다.") {
                let scene = UIApplication.shared.connectedScenes.first
                if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    sd.switchToGreetingViewController()
                }
            }
        }
    }
    
    private func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func timestampToString(value: Timestamp) -> String {
        let date = value.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let result = dateFormatter.string(from: date)
        return result
    }
}
