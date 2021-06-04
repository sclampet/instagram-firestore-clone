//
//  PostViewModel.swift
//  InstagramFirestore
//
//  Created by Scott Clampett on 5/6/21.
//

import UIKit

struct PostViewModel {
    var post: Post
    
    var imageUrl: URL? {
        return URL(string: post.imageUrl)
    }
    
    var caption: String {
        return post.caption
    }
    
    var likes: Int {
        return post.likes
    }
    
    var likesLabelText: String {
        return post.likes != 1 ? "\(post.likes) likes" : "\(post.likes) like"
    }
    
    var likeButtonTintColor: UIColor {
        return post.isLiked ? .red : .black
    }
    
    var likeButtonImage: UIImage? {
        return post.isLiked ? UIImage(named: "like_selected") : UIImage(named: "like_unselected")
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        return formatter.string(from: post.timestamp.dateValue(), to: Date())
    }
    
    var userProfileImageUrl: URL? {
        return URL(string: post.ownerImageUrl)
    }
    
    var username: String {
        return post.ownerUsername
    }

    init(post: Post) {
        self.post = post
    }
}
