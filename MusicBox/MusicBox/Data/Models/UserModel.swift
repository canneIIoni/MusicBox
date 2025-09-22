//
//  UserModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation

// MARK: - User
struct User: Codable {
    var id: String
    var username: String
    var email: String
    var profileImageData: Data?

    // Relacionamentos
    var reviews: [Review]
    var comments: [Comment]
}
