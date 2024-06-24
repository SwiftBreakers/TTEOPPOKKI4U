//
//  LocationItem.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/23/24.
//

import Foundation
import MessageKit
import CoreLocation


struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240) // 원하는 지도 크기
    }
}
