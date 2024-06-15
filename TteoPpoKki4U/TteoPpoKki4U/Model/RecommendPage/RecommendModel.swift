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
}

//public struct Bookmarked {
//    var title: String
//    var imageURL: String
//}

public struct DetailImage {
    var imageURL: String
}

struct MyModel {
  let color: UIColor
  var isDimmed: Bool
}
