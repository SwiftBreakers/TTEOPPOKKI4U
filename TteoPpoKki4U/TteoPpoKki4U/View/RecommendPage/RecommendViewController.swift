//
//  RecommendViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/05/30.
//

import UIKit
import Combine
import VerticalCardSwiper
import Firebase
import Kingfisher
import SkeletonView

public class RecommendViewController: UIViewController {
    
    private var cardSwiper: VerticalCardSwiper!
    private var viewModel = CardViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var card: Card?
    
    //이벤트 출력
    let eventContainerView = UIView()
    let eventContainerSubView = UIView()
    let eventContainerSubImageView = UIView()
    let closeButton = UIButton(type: .system)
    let doNotShowTodayButton = UIButton(type: .system)
    let eventImageView = UIImageView()
    let titleLabel = UILabel()
    
    let subTitleLabel = UILabel()
    //여기까지
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCardSwiper()
        Task {
            await viewModel.fetchData()
        }
        bind()
        //아래꺼 추가-이벤트오버레이
        setupEventOverlay()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellables.removeAll()
        Task {
            await viewModel.fetchData()
        }
        bind()
    }
    
  
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupCardSwiper() {
        cardSwiper = VerticalCardSwiper(frame: self.view.bounds)
        cardSwiper.datasource = self
        cardSwiper.delegate = self
        cardSwiper.register(MyCardCell.self, forCellWithReuseIdentifier: "MyCardCell")
        cardSwiper.isSkeletonable = true
        cardSwiper.isSideSwipingEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
            self.cardSwiper.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemGray5), animation: animation, transition: .crossDissolve(1.0))
        }
        self.view.addSubview(cardSwiper)
        SetConstraints()
    }
    
    private func SetConstraints() {
        cardSwiper.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func bind() {
        viewModel.$cards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.cardSwiper.reloadData()
                self?.cardSwiper.hideSkeleton()
            }
            .store(in: &cancellables)
    }
    
    public func didTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int) {
        let tappedCard = viewModel.card(at: index)
        let detailVC = DetailViewController()
        detailVC.card = tappedCard
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}


extension RecommendViewController: VerticalCardSwiperDatasource, VerticalCardSwiperDelegate {
    public func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        return viewModel.numberOfCards
    }
    
    public func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        let cell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "MyCardCell", for: index) as! MyCardCell
        let card = viewModel.card(at: index)
        // RecommendCardView에서 커스텀얼럿을 띄우기 위한 코드
        cell.customAlertViewController = self
        cell.configure(with: card)
        return cell
        
    }
    
}

extension RecommendViewController {
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 저장된 날짜와 현재 날짜 비교
        if shouldShowEvent() {
            showEventOverlay()
        }
    }
    
    func setupEventOverlay() {
        eventContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        eventContainerView.isHidden = true
        view.addSubview(eventContainerView)
        eventContainerView.addSubview(eventContainerSubView)
        eventContainerSubView.backgroundColor = UIColor.white
        eventContainerSubView.layer.cornerRadius = 4
        eventContainerSubView.addSubview(eventContainerSubImageView)
        eventContainerView.addSubview(titleLabel)
        eventContainerView.addSubview(subTitleLabel)
        
        eventContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        eventContainerSubView.snp.makeConstraints { make in
            make.center.equalToSuperview()
//            make.top.equalToSuperview().offset(200)
//            make.leading.equalToSuperview().offset(50)
            make.height.equalTo(300)
            make.width.equalTo(250)
        }
        
        eventContainerSubImageView.clipsToBounds = true
        eventContainerSubImageView.snp.makeConstraints { make in
            make.top.equalTo(eventContainerSubView.snp.top).offset(15)
            make.centerX.equalTo(eventContainerSubView)
//            make.top.equalToSuperview().offset(200)
//            make.leading.equalToSuperview().offset(50)
            make.height.equalTo(220)
            make.width.equalTo(220)
        }
        
        
        let eventImageView = UIImageView(image: UIImage(named: "sample"))
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.clipsToBounds = true
        eventContainerSubImageView.addSubview(eventImageView)
        
        eventImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(eventImageTapped))
                eventImageView.isUserInteractionEnabled = true
                eventImageView.addGestureRecognizer(tapGesture)
        
        titleLabel.text("리뷰 쓰고 커피 받아가세요!")
        titleLabel.font = ThemeFont.fontMedium(size: 14)

        titleLabel.textColor = UIColor(hexString: "353535")
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(eventContainerSubImageView.snp.bottom).offset(10)
//            make.leading.equalTo(eventContainerSubImageView.snp.leading).offset(10)
//            make.trailing.equalTo(eventContainerSubImageView.snp.trailing).offset(10)
            make.centerX.equalTo(eventContainerSubView)
        }
        
        subTitleLabel.text("기간 종료 후 20명 순차지급")
        subTitleLabel.font = ThemeFont.fontRegular(size: 12)

        subTitleLabel.textColor = UIColor(hexString: "353535")
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
//            make.leading.equalTo(titleLabel.snp.leading)
            make.centerX.equalTo(titleLabel)
        }
        
        closeButton.setTitle("닫기", for: .normal)
        closeButton.titleLabel?.font = ThemeFont.fontMedium(size: 14)
        closeButton.setTitleColor(UIColor(hexString: "FFFFFF"), for: .normal)
        closeButton.backgroundColor = UIColor(hexString: "FE724C")
        closeButton.layer.cornerRadius = 4
        closeButton.addTarget(self, action: #selector(hideEventOverlay), for: .touchUpInside)
        eventContainerView.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalTo(eventContainerSubView.snp.trailing)
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.top.equalTo(eventContainerSubView.snp.bottom).offset(10)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        doNotShowTodayButton.setTitle("오늘 하루 보지 않기", for: .normal)
        doNotShowTodayButton.titleLabel?.font = ThemeFont.fontRegular(size: 14)
        doNotShowTodayButton.setTitleColor(UIColor(hexString: "353535"), for: .normal)
        doNotShowTodayButton.backgroundColor = .white
        doNotShowTodayButton.layer.cornerRadius = 4
        doNotShowTodayButton.addTarget(self, action: #selector(doNotShowTodayButtonTapped), for: .touchUpInside)
        eventContainerView.addSubview(doNotShowTodayButton)
        
        doNotShowTodayButton.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton.snp.centerY)
            make.leading.equalTo(eventContainerSubView.snp.leading)
            make.width.equalTo(180)
            make.height.equalTo(40)
        }
    }
    
    @objc func eventImageTapped() {
        if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 3 // MyPageViewController가 탭바의 네번째에 있음
                    
                    if let myPageNavController = tabBarController.viewControllers?[3] as? UINavigationController,
                       let myPageVC = myPageNavController.viewControllers.first as? MyPageViewController {
                        myPageVC.showEventSceneViewController()
                        
                        
                    }
                }
    }
    
    func showEventOverlay() {
        eventContainerView.isHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc func hideEventOverlay() {
        eventContainerView.isHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc func doNotShowTodayButtonTapped() {
        let currentDate = Date()
        let userID = Auth.auth().currentUser?.uid ?? "guest" // Firebase Authentication을 사용하여 현재 사용자의 ID를 가져옵니다.
                    UserDefaults.standard.set(currentDate, forKey: "DoNotShowEventDate_\(userID)") // 사용자별로 날짜를 저장합니다.
                
        hideEventOverlay()
    }
    
    func shouldShowEvent() -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
//        if let savedDate = UserDefaults.standard.object(forKey: "DoNotShowEventDate") as? Date {
//            if calendar.isDate(currentDate, inSameDayAs: savedDate) {
//                return false
//            }
//        }
        let userID = Auth.auth().currentUser?.uid ?? "guest" // Firebase Authentication을 사용하여 현재 사용자의 ID를 가져오기
                  if let savedDate = UserDefaults.standard.object(forKey: "DoNotShowEventDate_\(userID)") as? Date { // 사용자별로 날짜를 불러오기
                    if calendar.isDate(currentDate, inSameDayAs: savedDate) {
                        return false
                    }
                }
        
        return true
    }
}

