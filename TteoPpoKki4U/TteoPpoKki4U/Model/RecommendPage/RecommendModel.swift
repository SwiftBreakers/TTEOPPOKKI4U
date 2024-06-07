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
    var longDescription: String
    var imageURL: String
    var image: UIImage?
    
    public init(title: String, description: String, imageURL: String, longDescription: String) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.longDescription = longDescription
    }
}
