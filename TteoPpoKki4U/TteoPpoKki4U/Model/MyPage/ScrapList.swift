//
//  MyScrap.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/30/24.
//

//MVP(중간발표) -> 그냥 리스팅을 해서 화면을 보여준다.
// 이후, 스크랩 목록을 누르면
// 해당 가게 정보를 모달로 띄워서 보여줌.

import Foundation

struct ScrapList {
    let storeId: UUID
    let store: String
    let rating: Float
    let address: String
}
