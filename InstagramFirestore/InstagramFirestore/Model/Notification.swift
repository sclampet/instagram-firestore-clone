//
//  Notification.swift
//  InstagramFirestore
//
//  Created by Scott Clampett on 5/10/21.
//

import Firebase

enum NotificationType: Int {
    case like
    case follow
    case comment
    
    var notificationMessage: String {
        switch self {
        case .like: return " liked your post"
        case .follow: return " started following you"
        case .comment: return " commented on your post"
        }
    }
}

struct Notification {
    let ownerUid: String
    let postId: String
    let postImageUrl: String?
    let timestamp: Timestamp
    let type: NotificationType
    let id: String
    let userProfileImageUrl: String
    let username: String
    
    var userIsFollowed = false
    
    init(dictionary: [String: Any]) {
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.postId = dictionary["postId"] as? String ?? ""
        self.postImageUrl = dictionary["postImageUrl"] as? String ?? ""
        self.id = dictionary["id"] as? String ?? ""
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .like
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
    }
}
