//
//  Double+Extension.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 6/4/24.
//

import Foundation

extension Double {
  /// 거리 표시(1000m를 넘으면 1km로 표시)
  var prettyDistance: String {
    guard self > -.infinity else { return "?" }

    let formatter = LengthFormatter()
    formatter.numberFormatter.maximumFractionDigits = 2

    if self >= 1000 {
      return formatter.string(fromValue: self / 1000, unit: LengthFormatter.Unit.kilometer)
    } else {
      let value = Double(Int(self)) // 미터로 표시할 땐 소수점 제거
      return formatter.string(fromValue: value, unit: LengthFormatter.Unit.meter)
    }
  }
}
