//
//  DiffableSectionModel.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/12/24.
//

import Foundation

enum DiffableSectionModel {
    
    case user
    case review
    
}

enum DiffableSectionItemModel: Hashable {
    
    case user(UserModel)
    case review(ReviewModel)
    
}
