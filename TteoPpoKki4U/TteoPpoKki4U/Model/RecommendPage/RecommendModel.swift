//
//  RecommendModel.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/05/30.
//

import Foundation
import UIKit

public struct Card {
    var title: String
    var description: String
    var longDescription1: String
    var longDescription2: String
    var imageURL: String
    var shopAddress: String
    var queryName: String
    var collectionImageURL1: String
    var collectionImageURL2: String
    var collectionImageURL3: String
    var collectionImageURL4: String
}

public struct DetailImage {
    var imageURL: String
}

struct Item {
    let imageURL: URL
    var isDimmed: Bool
}
