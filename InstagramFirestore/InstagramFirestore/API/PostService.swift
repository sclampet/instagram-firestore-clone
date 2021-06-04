//
//  PostService.swift
//  InstagramFirestore
//
//  Created by Scott Clampett on 5/6/21.
//

import UIKit
import Firebase

struct PostService {
    static func uploadPost(caption: String, image: UIImage, user: User, completionn: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = ["caption": caption,
                        "timestamp": Timestamp(date: Date()),
                        "likes": 0,
                        "imageUrl": imageUrl,
                        "ownerUid": uid,
                        "ownerImageUrl": user.profileImageUrl,
                        "ownerUsername":user.username] as [String : Any]
            
            FIRESTORE_COLLECTION_POSTS.addDocument(data: data, completion: completionn)
        }
    }
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //Get all the users that the currentUser is following
        FIRESTORE_COLLECTION_FOLLOWING.document(uid).collection(usersFollowingCollection).getDocuments { (snapshot, error) in
            if let error = error {
                print("DEBUG: Error getting users-following collection \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            let userFollowingIDs = documents.map({ $0.documentID })
            
            //Get all posts and go through each one to grab only the posts of the users that the currentUser is following AND the currentUsers posts
            FIRESTORE_COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
                if let error = error {
                    print("DEBUG: Error getting all posts in fetchPosts \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let allPosts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
                var followingPosts = [Post]()
                
                allPosts.forEach { (post) in
                    if (userFollowingIDs.contains(post.ownerUid) || post.ownerUid == uid) {
                        followingPosts.append(post)
                    }
                }
                
                completion(followingPosts)
            }
        }
    }
    
    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
        let query = FIRESTORE_COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("DEBUG: Error fetching posts with query \(error.localizedDescription)")
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            
            posts.sort { (post1, post2) -> Bool in
                return post1.timestamp.seconds > post2.timestamp.seconds
            }
            
            completion(posts)
        }
    }
    
    static func fetchPost(withPostId postId: String, completion: @escaping(Post) -> Void) {
        FIRESTORE_COLLECTION_POSTS.document(postId).getDocument { (snapshot, error) in
            if let err = error {
                print("DEBUG: Error fetch single post \(err.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot,
                  let data = snapshot.data() else { return }
            
            let post = Post(postId: snapshot.documentID, dictionary: data)
            completion(post)
        }
    }
    
    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FIRESTORE_COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes + 1])
        
        FIRESTORE_COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData([:]) { (error) in
            if let error = error {
                print("DEBUG: error adding user uid to post-like collection \(error.localizedDescription)")
            }
            
            FIRESTORE_COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).setData([:], completion: completion)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid  else { return }
        
        FIRESTORE_COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes - 1])
        
        FIRESTORE_COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete { (_) in
            FIRESTORE_COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).delete(completion: completion)
        }
    }
    
    static func checkIfPostIsLiked(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FIRESTORE_COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).getDocument { (snapshot, error) in
            guard let isLiked = snapshot?.exists else { return }
            
            completion(isLiked)
        }
    }
    
//    static func updateUserFeedAfterFollowing(user: User) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        let query = FIRESTORE_COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid)
//        
//        query.getDocuments { (snapshot, error) in
//            guard let documents = snapshot?.documents else { return }
//            
//            let docIDs = documents.map({ $0.documentID })
//            
//            docIDs.forEach { (id) in
//                FIRESTORE_COLLECTION_USERS
//                    .document(uid)
//                    .collection(usersFeedCollection)
//                    .document(id)
//                    .setData([:])
//            }
//        }
//    }
//    
//    static func fetchFeedPosts(completion: @escaping([Post]) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        FIRESTORE_COLLECTION_USERS.document(uid).collection(usersFeedCollection).getDocuments { (snapshot, error) in
//            if let error = error {
//                print("DEBUG: Error fetching user's feed collection \(error.localizedDescription)")
//                return
//            }
//            
//            
//        }
//    }
}
