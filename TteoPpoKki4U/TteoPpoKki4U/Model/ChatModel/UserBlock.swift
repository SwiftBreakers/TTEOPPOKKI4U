//
//  UserBlock.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/30/24.
//

import Foundation

struct UserBlock {
    
    var myUid: String
    var blockSenderNames: Set<String>
    
    
    func toDictionary() -> [String: Any] {
        return [
            "myUid": myUid,
            "blockSenderNames": Array(blockSenderNames) // Set을 Array로 변환
        ]
    }
}
