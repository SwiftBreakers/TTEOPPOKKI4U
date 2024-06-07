//
//  MyPageVM.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/29/24.
//

import Foundation
import Combine

class MyPageViewModel {
    
    let userManager = UserManager()
    //var
    
    
    let sections: [MyPageSection] = [
        MyPageSection(title: "Profile", options: [
            MyPageModel(icon: "person.crop.circle", title: "프로필 수정")
        ]),
        MyPageSection(title: "History", options: [
            MyPageModel(icon: "heart.fill", title: "나의 찜 목록"),
            MyPageModel(icon: "pencil.line", title: "내가 쓴 리뷰"),
        ]),
        MyPageSection(title: "Settings", options: [
            MyPageModel(icon: "gearshape.fill", title: "앱 환경 설정"),
            MyPageModel(icon: "power.circle", title: "로그아웃"),
            MyPageModel(icon: "message", title: "테스트")
        ])
    ]

    
}
