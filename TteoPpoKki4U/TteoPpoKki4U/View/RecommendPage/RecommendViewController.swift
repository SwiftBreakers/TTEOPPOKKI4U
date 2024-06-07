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

public class RecommendViewController: UIViewController {
    
    private var cardSwiper: VerticalCardSwiper!
    private var viewModel: CardViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModel = CardViewModel()
        setupCardSwiper()
        bind()
        Task {
            await viewModel.fetchData()
        }
    }
    
    private func setupCardSwiper() {
        cardSwiper = VerticalCardSwiper(frame: self.view.bounds)
        cardSwiper.datasource = self
        cardSwiper.delegate = self
        cardSwiper.register(MyCardCell.self, forCellWithReuseIdentifier: "MyCardCell")
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
                self?.reloadCollectionView()
            }
            .store(in: &cancellables)
    }
    
    private func reloadCollectionView() {
        cardSwiper.reloadData()
    }
    
    public func didTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int) {
        let tappedCard = viewModel.card(at: index)
        let detailVC = DetailViewController()
        detailVC.card = tappedCard
        present(detailVC, animated: true, completion: nil)
    }
}

extension RecommendViewController: VerticalCardSwiperDatasource, VerticalCardSwiperDelegate {
    public func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        return viewModel.numberOfCards
    }
    
    public func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        let cell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "MyCardCell", for: index) as! MyCardCell
        let card = viewModel.card(at: index)
        cell.titleLabel.text = card.title
        cell.descriptionLabel.text = card.description
        cell.imageView.image = card.image
        return cell
    }
    
}
