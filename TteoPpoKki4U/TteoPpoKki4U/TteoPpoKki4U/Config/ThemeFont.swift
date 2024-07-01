//
//  ThemeFont.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/30/24.
//

import UIKit

struct ThemeFont {
    
    static func fontELight (size: CGFloat = 18 ) -> UIFont {
        UIFont(name: "Pretendard-ExtraLight", size: size)!
    }
    static func fontRegular (size: CGFloat = 18 ) -> UIFont {
        UIFont(name: "Pretendard-Regular", size: size)!
    }
    static func fontMedium (size: CGFloat = 18 ) -> UIFont {
        UIFont(name: "Pretendard-Medium", size: size)!
    }
    static func fontBold (size: CGFloat = 18 ) -> UIFont {
        UIFont(name: "Pretendard-Bold", size: size)!
    }
    static func fontBlack (size: CGFloat = 18 ) -> UIFont {
        UIFont(name: "Pretendard-Black", size: size)!
    }

}
