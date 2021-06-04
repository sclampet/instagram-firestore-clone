//
//  UserCellViewModel.swift
//  InstagramFirestore
//
//  Created by Scott Clampett on 5/5/21.
//

import UIKit

struct UserCellViewModel {
    private let user: User
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var username: String? {
        return user.username
    }
    
    var fullname: String? {
        return user.fullname
    }
    
    init(user: User) {
        self.user = user
    }
}
