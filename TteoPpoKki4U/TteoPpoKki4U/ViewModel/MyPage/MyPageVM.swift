//
//  MyPageVM.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 5/29/24.
//

import Foundation

class MyPageVM {

    
    
    let sections: [MyPageSection] = [
        MyPageSection(title: "Profile", options: [
            MyPageModel(icon: "person.fill", title: "Personal Info")
        ]),
        MyPageSection(title: "Settings", options: [
            MyPageModel(icon: "heart.fill", title: "Favorite"),
            MyPageModel(icon: "star.fill", title: "My Reviews"),
            MyPageModel(icon: "gearshape.fill", title: "Settings")
        ]),
        MyPageSection(title: "", options: [
            MyPageModel(icon: "arrow.uturn.left", title: "Log Out")
        ])
    ]
}
