//
//  Constants.swift
//  InstagramFirestore
//
//  Created by Scott Clampett on 5/3/21.
//

import Firebase

let FIRESTORE_COLLECTION_USERS = Firestore.firestore().collection("users")
let FIRESTORE_COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let FIRESTORE_COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let FIRESTORE_COLLECTION_POSTS = Firestore.firestore().collection("posts")
let FIRESTORE_COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")

let usersCollection = "users-collection"
let usersFollowersCollection = "users-followers"
let usersFollowingCollection = "users-following"
let usersNotificationCollection = "users-notifications"
let usersFeedCollection = "users-feed"
