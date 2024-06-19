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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCardSwiper()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellables.removeAll()
    }
    public override func viewWillAppear(_ animated: Bool) {
        Task {
            await viewModel.fetchData()
        }
        bind()
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
