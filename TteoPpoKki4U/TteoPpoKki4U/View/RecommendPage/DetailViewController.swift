//
//  DetailViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/05.
//
import UIKit
import SnapKit
import Combine

class DetailViewController: UIViewController, UISearchBarDelegate {
    
    var card: Card?
    let shopAddressLabel = UILabel()
    let imageURL = UILabel()
    let shopAddressButton = UIButton()
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let longDescription1Label = UILabel()
    let longDescription2Label = UILabel()
    let collectionImageURL1 = UILabel()
    let collectionImageView1 = UIImageView()
    let collectionImageURL2 = UILabel()
    let collectionImageView2 = UIImageView()
    let collectionImageURL3 = UILabel()
    let collectionImageView3 = UIImageView()
    let collectionImageURL4 = UILabel()
    let collectionImageView4 = UIImageView()
    let contentView = UIView()
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .white
        
        return scrollView
    }()
    var isBookmarked = false {
        didSet {
            if isBookmarked {
                barBookmarkButton.image = .bookmark1
            } else {
                barBookmarkButton.image = .bookmark0
            }
        }
    }
    let viewModel = CardViewModel()
    let barBookmarkButton = UIBarButtonItem()
    let barShareButton = UIBarButtonItem()
    var cancellables = Set<AnyCancellable>()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
    
    let flowlayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8.0
        layout.itemSize = Const.itemSize
        layout.minimumLineSpacing = Const.itemSpacing
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private enum Const {
        static let itemSize = CGSize(width: 300, height: 400)
        static let itemSpacing = 24.0
        
        static var insetX: CGFloat {
            (UIScreen.main.bounds.width - Self.itemSize.width) / 2.0
        }
        static var collectionViewContentInset: UIEdgeInsets {
            UIEdgeInsets(top: 0, left: Self.insetX, bottom: 0, right: Self.insetX)
        }
    }
    //    private var items = (0...3).map { _ in
    //      MyModel(color: randomColor, isDimmed: true)
    //    }
    var items: [Item] = []
    private var previousIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureView()
        setupCollectionView()
        //        navigationController?.hidesBarsOnSwipe = true
        makeBarButton()
        bind()
        items = [
            Item(imageURL: URL(string: card!.collectionImageURL1)!, isDimmed: false),
            Item(imageURL: URL(string: card!.collectionImageURL2)!, isDimmed: false),
            Item(imageURL: URL(string: card!.collectionImageURL3)!, isDimmed: false),
            Item(imageURL: URL(string: card!.collectionImageURL4)!, isDimmed: false)
        ]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let title = card?.title {
            Task {
                await viewModel.fetchBookmarkStatus(title: title)
            }
        }
    }
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: DetailCollectionViewCell.identifier)
        collectionView.frame = view.bounds
        collectionView.isPagingEnabled = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .systemGray6
        collectionView.clipsToBounds = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = Const.collectionViewContentInset
        collectionView.decelerationRate = .fast
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
        if let image = UIImage(named: "share")?.withRenderingMode(.alwaysTemplate) {
            barShareButton.image = image
            barShareButton.tintColor = ThemeColor.mainOrange
        }
        
        barShareButton.style = .plain
        barShareButton.target = self
        barShareButton.action = #selector(shareButtonTapped)
        
        if let image = UIImage(named: "bookmark0")?.withRenderingMode(.alwaysTemplate) {
            barBookmarkButton.image = image
            barBookmarkButton.tintColor = ThemeColor.mainOrange
        }
        barBookmarkButton.style = .plain
        barBookmarkButton.target = self
        barBookmarkButton.action = #selector(bookmarkButtonTapped)
        
        navigationItem.rightBarButtonItems = [barShareButton, barBookmarkButton]
    }
    @objc func bookmarkButtonTapped() {
        if isBookmarked {
            if let image = UIImage(named: "bookmark0")?.withRenderingMode(.alwaysTemplate) {
                barBookmarkButton.image = image
                barBookmarkButton.tintColor = ThemeColor.mainOrange
            }
            let bookmark0Image = UIImageView()
            bookmark0Image.image = .bookmark0
            showCustomAlert(image: bookmark0Image.image!, message: "북마크에서 삭제 되었어요.")
            viewModel.deleteBookmarkItem(title: titleLabel.text!)
        } else {
            if let image = UIImage(named: "bookmark1")?.withRenderingMode(.alwaysTemplate) {
                barBookmarkButton.image = image
                barBookmarkButton.tintColor = ThemeColor.mainOrange
            }
            let bookmark1Image = UIImageView()
            bookmark1Image.image = .bookmark1
            showCustomAlert(image: bookmark1Image.image!, message: "북마크에 추가 되었어요.")
            viewModel.createBookmarkItem(title: titleLabel.text!, imageURL: imageURL.text!)
        }
    }
    private func bind() {
        viewModel.$isBookmarked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBookmarked in
                self?.isBookmarked = isBookmarked
            }
            .store(in: &cancellables)
    }
    
    private func configureView() {
        guard let card = card else { return }
        titleLabel.text = card.title
        descriptionLabel.text = card.description
        descriptionLabel.font = ThemeFont.fontRegular(size: 20)
        longDescription1Label.text = card.longDescription1
        longDescription2Label.text = card.longDescription2
        imageURL.text = card.imageURL
        
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
        
        longDescription1Label.font = ThemeFont.fontRegular(size: 16)
        longDescription1Label.numberOfLines = 100
        longDescription1Label.textAlignment = .left
        
        longDescription2Label.font = ThemeFont.fontRegular(size: 16)
        longDescription2Label.numberOfLines = 100
        longDescription2Label.textAlignment = .left
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageView)
        imageView.addSubview(titleLabel)
        imageView.addSubview(descriptionLabel)
        contentView.addSubview(shopAddressLabel)
        contentView.addSubview(longDescription1Label)
        contentView.addSubview(collectionView)
        contentView.addSubview(longDescription2Label)
        contentView.addSubview(shopAddressButton)
        
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
        longDescription1Label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).offset(-20)
        }
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(longDescription1Label.snp.bottom).offset(20)
            make.height.equalTo(200)
        }
        longDescription2Label.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).offset(-20)
        }
        shopAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(longDescription2Label.snp.bottom).offset(20)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        shopAddressButton.snp.makeConstraints { make in
            make.top.equalTo(longDescription2Label.snp.bottom).offset(20)
            make.leading.equalTo(shopAddressLabel.snp.trailing).offset(20)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).offset(-150)
            make.centerY.equalTo(shopAddressLabel)
        }
    }
    
    @objc func moveToMap() {
        guard let keyword = card?.queryName else { return }
        
        NetworkManager.shared.fetchAPI(query: keyword) {[weak self] stores in
            
            guard let tabBarController = self?.tabBarController else { return }
            tabBarController.selectedIndex = 1
            
            if let navController = tabBarController.selectedViewController as? UINavigationController,
               let mapVC = navController.viewControllers.first as? MapViewController {
                mapVC.searchLocation(query: self!.card!.queryName, for: [])
                mapVC.storeInfoView.isHidden = false
            }
            
        }
    }
}
extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.identifier, for: indexPath) as! DetailCollectionViewCell
        let item = self.items[indexPath.item]
        cell.prepare(imageURL: item.imageURL, isDimmed: item.isDimmed)
        return cell
    }
}
extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = Const.itemSize.width + Const.itemSpacing
        let index = round(scrolledOffsetX / cellWidth)
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrolledOffset = scrollView.contentOffset.x + scrollView.contentInset.left
        let cellWidth = Const.itemSize.width + Const.itemSpacing
        let index = Int(round(scrolledOffset / cellWidth))
        
        // index가 items 배열의 유효한 인덱스인지 확인
        guard index >= 0 && index < items.count else { return }

        if let previousIndex = previousIndex, previousIndex != index {
            // previousIndex도 유효한 인덱스인지 확인
            if previousIndex >= 0 && previousIndex < items.count {
                items[previousIndex].isDimmed = true
            }
            items[index].isDimmed = false
            collectionView.reloadItems(at: [IndexPath(item: previousIndex, section: 0), IndexPath(item: index, section: 0)])
            self.previousIndex = index
        } else {
            items[index].isDimmed = false
            self.previousIndex = index
        }
    }

}
private var randomColor: UIColor {
    UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)}
