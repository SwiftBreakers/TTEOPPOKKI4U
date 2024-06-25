//
//  Message.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/20.
//

import Foundation
import MessageKit
import UIKit
import Firebase
import CoreLocation

struct Message: MessageType {
    
    let userManager = UserManager()
    
    let id: String?
    var messageId: String {
        return id ?? UUID().uuidString
    }
    let content: String
    let sentDate: Date
    let sender: SenderType
    var kind: MessageKind {
        if let image = image {
            let mediaItem = ImageMediaItem(image: image)
            return .photo(mediaItem)
        } else if let location = location {
            let locationItem = Location(location: location)
            return .location(locationItem)
        } else {
            return .text(content)
        }
    }
    
    var image: UIImage?
    var location: CLLocation?
    var downloadURL: URL?
    
    var chatReportCount: Int = 0 // 신고 횟수
    var isActive: Bool = true // 활성 여부
    
    init(user: User, content: String, displayName: String) {
        sender = Sender(senderId: user.uid, displayName: displayName)
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    init(customUser: CustomUser, content: String, displayName: String) {
        sender = Sender(senderId: customUser.uid, displayName: displayName)
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    init(user: User, image: UIImage, displayName: String) {
        sender = Sender(senderId: user.uid, displayName: displayName)
        self.image = image
        sentDate = Date()
        content = ""
        id = nil
    }
    
    init(customUser: CustomUser, image: UIImage, displayName: String) {
        sender = Sender(senderId: customUser.uid, displayName: displayName)
        self.image = image
        sentDate = Date()
        content = ""
        id = nil
    }
    
    init(user: User, location: CLLocation, displayName: String) {
        sender = Sender(senderId: user.uid, displayName: displayName)
        self.location = location
        sentDate = Date()
        content = ""
        id = nil
    }
    
    init(customUser: CustomUser, location: CLLocation, displayName: String) {
        sender = Sender(senderId: customUser.uid, displayName: displayName)
        self.location = location
        sentDate = Date()
        content = ""
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentDate = data["created"] as? Timestamp,
              let senderId = data["senderId"] as? String,
              let senderName = data["senderName"] as? String else { return nil }
        id = document.documentID
        self.sentDate = sentDate.dateValue()
        sender = Sender(senderId: senderId, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
            location = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
            location = nil
        } else if let latitude = data["latitude"] as? CLLocationDegrees, let longitude = data["longitude"] as? CLLocationDegrees {
            location = CLLocation(latitude: latitude, longitude: longitude)
            content = ""
            downloadURL = nil
        } else {
            return nil
        }
    }
    
    static func fetchDisplayName(userManager: UserManager, completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        userManager.fetchUserData(uid: uid) { error, snapshot in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            guard let dictionary = snapshot?.value as? [String: Any] else {
                completion(nil)
                return
            }
            let currentName = (dictionary[db_nickName] as? String) ?? "Unknown"
            completion(currentName)
        }
    }
}

extension Message: DatabaseRepresentation {
    var representation: [String : Any] {
        var representation: [String: Any] = [
            "created": sentDate,
            "senderId": sender.senderId,
            "senderName": sender.displayName,
            "chatReportCount": chatReportCount,
            "isActive": isActive
        ]
        
        if let url = downloadURL {
            representation["url"] = url.absoluteString
        } else if let location = location {
            representation["latitude"] = location.coordinate.latitude
            representation["longitude"] = location.coordinate.longitude
        } else {
            representation["content"] = content
        }
        
        return representation
    }
}

extension Message: Comparable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}

struct BlockedUser {
    let uid: String
}
