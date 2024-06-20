//
//  MessageModel.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/20/24.
//

import Foundation
import Firebase

struct MessageModel {
    
    var title: String // 메세지에 올라가는 내용
    var writerUid: String // 작성자 uid
    var writerNickname: String // 작성자 닉네임
    var timestamp: Timestamp // 작성 시간
    var otherNickname: String // 상대 닉네임 배열
    var otherUid: String // 상대 uid
    var profileImageURL: String // 상대 프로필 url
    var region: String // 대화방 지역
    var isReported: Bool // 신고 상태
    var isDeleted: Bool // 삭제 상태
    var isFromCurrentUser: Bool // 현재 사용자가 작성자인지 여부

        init(dictionary: [String: Any]) {
            self.title = dictionary["title"] as? String ?? ""
            self.writerUid = dictionary["writerUid"] as? String ?? ""
            self.writerNickname = dictionary["writerNickname"] as? String ?? ""
            self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
            self.otherNickname = dictionary["otherNickname"] as? String ?? ""
            self.otherUid = dictionary["otherUid"] as? String ?? ""
            self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
            self.region = dictionary["region"] as? String ?? ""
            self.isReported = dictionary["isReported"] as? Bool ?? false
            self.isDeleted = dictionary["isDeleted"] as? Bool ?? false
            self.isFromCurrentUser = (dictionary["writerUid"] as? String ?? "") == Auth.auth().currentUser?.uid
        }
    
}
