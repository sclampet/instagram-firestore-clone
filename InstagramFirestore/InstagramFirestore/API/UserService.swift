//
//  UserService.swift
//  InstagramFirestore
//
//  Created by Scott Clampett on 5/3/21.
//

import Firebase

struct UserService {
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        FIRESTORE_COLLECTION_USERS.document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("DEBUG: Error getting user info \(error.localizedDescription)")
            }
            
            guard let dictionary = snapshot?.data() else { return }
            
            completion(User(dictionary: dictionary))
        }
    }
    
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        FIRESTORE_COLLECTION_USERS.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            let users = snapshot.documents.map({ User(dictionary: $0.data()) })
            
            completion(users)
        }
    }
    
    static func follow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        FIRESTORE_COLLECTION_FOLLOWING.document(currentUid).collection(usersFollowingCollection).document(uid).setData([:]) { (error) in
            if let error = error {
                print("DEBUG: error following user \(error.localizedDescription)")
                return
            }
            
            FIRESTORE_COLLECTION_FOLLOWERS.document(uid).collection(usersFollowersCollection).document(currentUid).setData([:], completion: completion)
        }
    }
    
    static func unfollow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        FIRESTORE_COLLECTION_FOLLOWING.document(currentUid).collection(usersFollowingCollection).document(uid).delete { (error) in
            if let error = error {
                print("DEBUG: error unfollowing user \(error.localizedDescription)")
                return
            }
            FIRESTORE_COLLECTION_FOLLOWERS.document(uid).collection(usersFollowersCollection).document(currentUid).delete(completion: completion)
        }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        FIRESTORE_COLLECTION_FOLLOWING.document(currentUid).collection(usersFollowingCollection).document(uid).getDocument { (snapshot, error) in
            guard let isFollowed = snapshot?.exists else { return }
            
            completion(isFollowed)
        }
    }
    
    static func fetchUserStats(uid: String, completion: @escaping(UserStats) -> Void) {
        
        FIRESTORE_COLLECTION_FOLLOWERS.document(uid).collection(usersFollowersCollection).getDocuments { (snapshot, _) in
            let followers = snapshot?.documents.count ?? 0
            
            FIRESTORE_COLLECTION_FOLLOWING.document(uid).collection(usersFollowingCollection).getDocuments { (snapshot, _) in
                let following = snapshot?.documents.count ?? 0
                
                FIRESTORE_COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { (snapshot, _) in
                    let posts = snapshot?.documents.count ?? 0
                    
                    completion(UserStats(followers: followers, following: following, posts: posts))
                }
                
            }
        }
    }
}
