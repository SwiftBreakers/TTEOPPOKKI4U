//
//  RecommendViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/05/30.
//

import UIKit
import VerticalCardSwiper

public class RecommendViewController: UIViewController {
    
    private var cardSwiper: VerticalCardSwiper!
    private var viewModel: CardViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewModel = CardViewModel()
        setupCardSwiper()
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
        return cell
    }
}

