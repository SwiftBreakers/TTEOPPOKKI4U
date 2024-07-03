//
//  EventSceneViewController.swift
//  TteoPpoKki4U
//
//  Created by 김건응 on 6/26/24.
//

import Foundation
import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseStorage

class EventSceneViewController: UIViewController {
    
    var reviewButton: UIButton = {
        
        let reviewButton = UIButton(type: .system)
        return reviewButton
    }()
    
    //    var backButton: UIButton = {
    //
    //        let button = UIButton(type: .system)
    //        let image = UIImage(systemName: "chevron.backward.2")
    //        button.tintColor = .gray
    //        button.setImage(image, for: .normal)
    //
    //        button.addTarget(nil, action: #selector(backButtonTapped), for: .touchUpInside)
    //        return button
    //
    //    }()
    //
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "이벤트"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    var customNavigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
        
    }()
    //        let mainView = UIImageView(image: UIImage(named: "coffee2"))
    
//    let mainView = UIImageView(image: UIImage(named: "coffee2"))
        let mainView = UIImageView()

    let imageTitleLabel = UILabel()
    let imageSubTitleLabel = UILabel()
    let eventTitleLabel = UILabel()
    let eventSubTitleLabel = UILabel()
    
    
    
    
    
    
    
    
    let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradient.locations = [0.3, 1.0]
        return gradient
    }()
    
    
    
    
    
    
    //    private var collectionView: UICollectionView!
    //    private let items: [UIImage] = [
    //        UIImage(named: "coffee1")!,
    //        UIImage(named: "coffee2")!
    //    ]
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //        setupCustomNavigationBar()
        //        setupBackButton()
        bottomReviewMoveButton()
        //
        //        setupCollectionView()
        //        title = "이벤트"
        navigationController?.navigationBar.tintColor = ThemeColor.mainOrange
        setupMainImageView()
        fetchEventData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true // 탭바 숨기기
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false // 탭바 다시 표시
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = mainView.bounds
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        
    }
    
    func setupBackButton() {
        
        navigationController?.isNavigationBarHidden = true
    }
    
    func setupCustomNavigationBar() {
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
            
        }
        
        
        //        customNavigationBar.addSubview(backButton)
        customNavigationBar.addSubview(titleLabel)
        
        //        backButton.snp.makeConstraints { make in
        //            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        //            make.leading.equalToSuperview().offset(20)
        //            make.trailing.equalToSuperview().offset(-340)
        //            make.height.equalTo(30)
        //        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        
        
        
        
    }
    
    func bottomReviewMoveButton() {
        
        reviewButton.setTitle("구글폼 작성하러 가기", for: .normal)
        reviewButton.titleLabel?.font = ThemeFont.fontBold(size: 16)
        reviewButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
        reviewButton.backgroundColor = UIColor(hexString: "FE724C")
        reviewButton.layer.cornerRadius = 5
        reviewButton.addTarget(self, action: #selector(reviewButtonTapped), for: .touchUpInside)
        
        view.addSubview(reviewButton)
        
        reviewButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
            make.width.equalTo(250)
        }
        
    }
    
    @objc func reviewButtonTapped() {
        if let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSeO5j_SxEsXd-dlzqK6B6eObwrQjei1npYv097z42Eokgwcwg/viewform") { // 원하는 링크로 변경
            UIApplication.shared.open(url)
        }
    }
    
    func setupMainImageView() {
        
        
        
        //        let mainView = UIImageView(image: UIImage(named: "coffee2"))
        mainView.contentMode = .scaleAspectFill
        mainView.clipsToBounds = true
        //        mainView.backgroundColor = UIColor(hexString: "FEFEFE")
        
        
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY).offset(50)
        }
        
        mainView.layer.addSublayer(gradientLayer)
        
//        imageTitleLabel.text = "리뷰 작성하고"
        imageTitleLabel.textColor = UIColor(hexString: "FFFFFF")
        imageTitleLabel.font = ThemeFont.fontRegular(size: 20)
        
        
        view.addSubview(imageTitleLabel)
        imageTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(320)
            
        }
        
//        imageSubTitleLabel.text = "커피 마실래?"
        imageSubTitleLabel.textColor = UIColor(hexString: "FFFFFF")
        imageSubTitleLabel.font = ThemeFont.fontBold(size: 48)
        
        view.addSubview(imageSubTitleLabel)
        imageSubTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(imageTitleLabel.snp.bottom).offset(10)
        }
        
//        eventTitleLabel.text = "구글폼을 제출해주시면 커피 쿠폰을 드려요!"
        eventTitleLabel.textColor = UIColor(hexString: "353535")
        eventTitleLabel.font = ThemeFont.fontBold(size: 16)
        
        view.addSubview(eventTitleLabel)
        eventTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.top).offset(540)
        }
        
//        eventSubTitleLabel.text = """
//        떡볶이 맛집을 다녀오신 후, 리뷰를 작성해주세요!
//        20분께 스타벅스 커피 쿠폰을 드립니다.
//        """
        eventSubTitleLabel.textColor = UIColor(hexString: "353535")
        eventSubTitleLabel.font = ThemeFont.fontRegular(size: 14)
        eventSubTitleLabel.numberOfLines = 0 // 여러 줄의 텍스트를 표시하기 위해 설정
        eventSubTitleLabel.textAlignment = .center
        
        view.addSubview(eventSubTitleLabel)
        eventSubTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(eventTitleLabel.snp.bottom).offset(10)
        }
        
        
    }
    
    func fetchEventData() {
            let db = Firestore.firestore()
            let storage = Storage.storage()
            
            db.collection("events").document("event1").getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let imageTitle = data?["imageTitle"] as? String ?? ""
                    let imageSubTitle = data?["imageSubTitle"] as? String ?? ""
                    let eventTitle = data?["eventTitle"] as? String ?? ""
                    var eventSubTitle = data?["eventSubTitle"] as? String ?? ""
                    let imageURL = data?["imageURL"] as? String ?? ""
                    
                    eventSubTitle = eventSubTitle.replacingOccurrences(of: "\\n", with: "\n")
                    
                    self.imageTitleLabel.text = imageTitle
                    self.imageSubTitleLabel.text = imageSubTitle
                    self.eventTitleLabel.text = eventTitle
                    self.eventSubTitleLabel.text = eventSubTitle
                    
                    if !imageURL.isEmpty {
                        let storageRef = storage.reference(forURL: imageURL)
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                print("Error getting download URL: \(error)")
                            } else if let url = url {
                                URLSession.shared.dataTask(with: url) { data, response, error in
                                    if let data = data, error == nil {
                                        DispatchQueue.main.async {
                                            self.mainView.image = UIImage(data: data)
                                        }
                                    }
                                }.resume()
                            }
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    
}

    
//
//    private func setupCollectionView() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 20
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) // 상단 인셋을 0으로 설정
//
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .white
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.decelerationRate = .fast
//        collectionView.showsHorizontalScrollIndicator = false
//        
//        collectionView.register(EventSceneCollectionViewCell.self, forCellWithReuseIdentifier: "EventSceneCollectionViewCell")
//        
////        view.addSubview(collectionView)
//        
////        collectionView.snp.makeConstraints { make in
////            make.top.equalTo(view.snp.top)
////            make.bottom.equalTo(view.snp.centerY)
////            make.leading.equalTo(view.snp.leading)
////            make.trailing.equalTo(view.snp.trailing)
////        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return items.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventSceneCollectionViewCell", for: indexPath) as! EventSceneCollectionViewCell
//        cell.configure(with: items[indexPath.item])
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width * 0.8, height: collectionView.frame.height)
//    }
//    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
//        
//        var offset = targetContentOffset.pointee
//        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
//        let roundedIndex = round(index)
//        
//        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
//        targetContentOffset.pointee = offset
//    }
//}



    
//    let titleLabel: UILabel = {
//            let label = UILabel()
//            label.font = UIFont.boldSystemFont(ofSize: 24)
//            label.textColor = .black
//            label.textAlignment = .center
//            label.numberOfLines = 0
//            return label
//        }()
//        
//        let descriptionLabel: UILabel = {
//            let label = UILabel()
//            label.font = UIFont.systemFont(ofSize: 18)
//            label.textColor = .darkGray
//            label.textAlignment = .center
//            label.numberOfLines = 0
//            return label
//        }()
//        
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            view.backgroundColor = .white
//            setupViews()
//        }
//        
//        func setupViews() {
//            view.addSubview(titleLabel)
//            view.addSubview(descriptionLabel)
//            
//            titleLabel.snp.makeConstraints { make in
//                make.centerX.equalToSuperview()
//                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
//                make.leading.equalToSuperview().offset(20)
//                make.trailing.equalToSuperview().offset(-20)
//            }
//            
//            descriptionLabel.snp.makeConstraints { make in
//                make.centerX.equalToSuperview()
//                make.top.equalTo(titleLabel.snp.bottom).offset(20)
//                make.leading.equalToSuperview().offset(20)
//                make.trailing.equalToSuperview().offset(-20)
//            }
//        }
//        
//        func configure(with title: String, description: String) {
//            titleLabel.text = title
//            descriptionLabel.text = description
        
    

