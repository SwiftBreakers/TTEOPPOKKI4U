//
//  DetailViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/05.
//
import UIKit
import SnapKit

class DetailViewController: UIViewController {
    
    var card: Card?
    var swipeRecognizer: UISwipeGestureRecognizer!
    let shopAddressLabel = UILabel()
    let shopAddressButton = UIButton()
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let longDescriptionLabel = UILabel()
    let contentView = UIView()
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .white
        
        return scrollView
    }()
    var isBookmarked = false
    let barBookmarkButton = UIBarButtonItem()
    let barShareButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureView()
        navigationController?.hidesBarsOnSwipe = true
        makeBarButton()
    }
    @objc func shareButtonTapped() {
        var shareItems = [String]()
        if let text = self.titleLabel.text {
            shareItems.append(text)
        }
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func makeBarButton() {
        barShareButton.title = "공유하기"
        barShareButton.style = .plain
        barShareButton.target = self
        barShareButton.action = #selector(shareButtonTapped)
        
        if isBookmarked == false {
            barBookmarkButton.image = .bookmark0
        } else {
            barBookmarkButton.image = .bookmark1
        }
        barBookmarkButton.style = .plain
        barBookmarkButton.target = self
        barBookmarkButton.action = #selector(bookmarkButtonTapped)
        
        navigationItem.rightBarButtonItems = [barShareButton, barBookmarkButton]
    }
    @objc func bookmarkButtonTapped() {
        print(#function)
        if isBookmarked == false {
            barBookmarkButton.image = .bookmark1
            isBookmarked = true
        } else {
            barBookmarkButton.image = .bookmark0
            isBookmarked = false
        }
    }
    
    private func configureView() {
        guard let card = card else { return }
        titleLabel.text = card.title
        descriptionLabel.text = card.description
        longDescriptionLabel.text = card.longDescription
        
        let addressString = NSMutableAttributedString(string: card.shopAddress)
        addressString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: card.shopAddress.count))
        shopAddressButton.setAttributedTitle(addressString, for: .normal)
        
        if let url = URL(string: card.imageURL) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = nil // Placeholder image or nil
        }
    }
    
    private func setupViews() {
        
        view.backgroundColor = .white
        
        contentView.backgroundColor = .white
        
        imageView.contentMode = .scaleToFill
        
        titleLabel.textColor = .white
        titleLabel.font = ThemeFont.fontBold(size: 40)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        
        descriptionLabel.textColor = .white
        descriptionLabel.font = ThemeFont.fontRegular(size: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        
        shopAddressLabel.text = "주소"
        shopAddressLabel.font = ThemeFont.fontBold(size: 18)
        
        shopAddressButton.setTitleColor(.black, for: .normal)
        shopAddressButton.titleLabel?.font = ThemeFont.fontRegular(size: 18)
        shopAddressButton.titleLabel?.numberOfLines = 2
        shopAddressButton.addTarget(self, action: #selector(moveToMap), for: .touchUpInside)
        
        longDescriptionLabel.font = ThemeFont.fontRegular(size: 16)
        longDescriptionLabel.numberOfLines = 100
        longDescriptionLabel.textAlignment = .left
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageView)
        imageView.addSubview(titleLabel)
        imageView.addSubview(descriptionLabel)
        contentView.addSubview(shopAddressLabel)
        contentView.addSubview(shopAddressButton)
        contentView.addSubview(longDescriptionLabel)
        
        //오토레이아웃 설정
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.leading.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide)
            make.height.equalTo(500)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
            make.leading.equalTo(imageView.snp.leading).offset(30)
            make.trailing.equalTo(imageView.snp.trailing).offset(-30)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(imageView.snp.bottom).offset(-50)
            make.leading.equalTo(imageView.snp.leading).offset(30)
            make.trailing.equalTo(imageView.snp.trailing).offset(-30)
            make.left.equalTo(titleLabel)
        }
        shopAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
        }
        shopAddressButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.equalTo(shopAddressLabel.snp.trailing).offset(20)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).offset(-150)
            make.centerY.equalTo(shopAddressLabel)
        }
        
        longDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(shopAddressLabel.snp.bottom).offset(20)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    @objc func moveToMap() {
        print(#function)
        
    }
    
}
