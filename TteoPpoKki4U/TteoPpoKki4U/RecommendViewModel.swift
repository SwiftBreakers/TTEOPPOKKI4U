//
//  RecommendViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import Foundation

public class CardViewModel {
    private var cards: [Card] = []

    public var numberOfCards: Int {
        return cards.count
    }

    public init() {
        // 예제 데이터
        self.cards = [
            Card(id: 0, title: "Card 1", description: "This is the first card"),
            Card(id: 1, title: "Card 2", description: "This is the second card"),
            Card(id: 2, title: "Card 3", description: "This is the third card")
        ]
    }

    public func card(at index: Int) -> Card {
        return cards[index]
    }
}


