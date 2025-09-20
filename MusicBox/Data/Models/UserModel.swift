//
//  UserModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation

// MARK: - User
class User {
    var id: String
    var username: String
    var email: String
    var profileImageData: Data?

    // Relacionamentos
    var reviews: [Review]
    var comments: [Comment]

    init(id: String,
         username: String,
         email: String,
         profileImageData: Data? = nil,
         reviews: [Review] = [],
         comments: [Comment] = []) {

        self.id = id
        self.username = username
        self.email = email
        self.profileImageData = profileImageData
        self.reviews = reviews
        self.comments = comments
    }
}
