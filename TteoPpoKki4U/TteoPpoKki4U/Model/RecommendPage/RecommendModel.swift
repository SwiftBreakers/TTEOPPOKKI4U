//
//  RecommendModel.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/05/30.
//

import Foundation

public struct Card {
    public let id: Int
    public let title: String
    public let description: String

    public init(id: Int, title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}
