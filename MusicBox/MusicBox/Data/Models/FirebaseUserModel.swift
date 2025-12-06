//
//  FirebaseUserModel.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//

import Foundation

struct DBUser: Codable {
    let userId: String
    let username: String?
    let email: String?
    let isAnonymous: Bool?
    let photoUrl: String?
    let dateCreated: Date?
    var isPremium: Bool?
    
    // Music-related data (to be implemented later)
    var savedAlbums: [String]? // Album IDs
    var savedSongs: [String]? // Song IDs
    var likedAlbums: [String]? // Album IDs
    var likedSongs: [String]? // Song IDs
    var reviews: [String]? // Review IDs
    var comments: [String]? // Comment IDs
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.username = nil // Can be set later by user
        self.email = auth.email
        self.isAnonymous = auth.isAnonymous
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.savedAlbums = nil
        self.savedSongs = nil
        self.likedAlbums = nil
        self.likedSongs = nil
        self.reviews = nil
        self.comments = nil
    }
    
    init(
        userId: String,
        username: String? = nil,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = false,
        savedAlbums: [String]? = nil,
        savedSongs: [String]? = nil,
        likedAlbums: [String]? = nil,
        likedSongs: [String]? = nil,
        reviews: [String]? = nil,
        comments: [String]? = nil
    ) {
        self.userId = userId
        self.username = username
        self.email = email
        self.isAnonymous = isAnonymous
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.savedAlbums = savedAlbums
        self.savedSongs = savedSongs
        self.likedAlbums = likedAlbums
        self.likedSongs = likedSongs
        self.reviews = reviews
        self.comments = comments
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username = "username"
        case email = "email"
        case isAnonymous = "is_anonymous"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "is_premium"
        case savedAlbums = "saved_albums"
        case savedSongs = "saved_songs"
        case likedAlbums = "liked_albums"
        case likedSongs = "liked_songs"
        case reviews = "reviews"
        case comments = "comments"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.savedAlbums = try container.decodeIfPresent([String].self, forKey: .savedAlbums)
        self.savedSongs = try container.decodeIfPresent([String].self, forKey: .savedSongs)
        self.likedAlbums = try container.decodeIfPresent([String].self, forKey: .likedAlbums)
        self.likedSongs = try container.decodeIfPresent([String].self, forKey: .likedSongs)
        self.reviews = try container.decodeIfPresent([String].self, forKey: .reviews)
        self.comments = try container.decodeIfPresent([String].self, forKey: .comments)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.username, forKey: .username)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.savedAlbums, forKey: .savedAlbums)
        try container.encodeIfPresent(self.savedSongs, forKey: .savedSongs)
        try container.encodeIfPresent(self.likedAlbums, forKey: .likedAlbums)
        try container.encodeIfPresent(self.likedSongs, forKey: .likedSongs)
        try container.encodeIfPresent(self.reviews, forKey: .reviews)
        try container.encodeIfPresent(self.comments, forKey: .comments)
    }
}
