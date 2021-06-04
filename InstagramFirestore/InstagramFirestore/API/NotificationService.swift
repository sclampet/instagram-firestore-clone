//
//  NotificationService.swift
//  InstagramFirestore
//
//  Created by Scott Clampett on 5/10/21.
//

import Firebase

struct NotificationService {
    static func uploadNotifications(toUser uid: String, fromUser: User, type: NotificationType, post: Post? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid, uid != currentUid else { return }
        
        let docRef = FIRESTORE_COLLECTION_NOTIFICATIONS
            .document(uid)
            .collection(usersNotificationCollection)
            .document()
        
        var data: [String: Any] = [
            "timestamp": Timestamp(date: Date()),
            "ownerUid": currentUid,
            "type": type.rawValue,
            "id": docRef.documentID,
            "userProfileImageUrl": fromUser.profileImageUrl,
            "username": fromUser.username]
        
        if let post = post {
            data["postId"] = post.postId
            data["postImageUrl"] = post.imageUrl
        }
        
        docRef.setData(data)
    }
    
    static func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = FIRESTORE_COLLECTION_NOTIFICATIONS
            .document(currentUid)
            .collection(usersNotificationCollection)
            .order(by: "timestamp", descending: true)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            let notifications = documents.map({ Notification(dictionary: $0.data()) })
            completion(notifications)
        }
    }
}
