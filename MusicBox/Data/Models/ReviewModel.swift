//
//  ReviewModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation

// MARK: - Review
class Review {
    var id: UUID
    var userId: String
    var albumId: UUID
    var text: String
    var grade: Double
    var isLiked: Bool
    var isLogged: Bool
    var isSaved: Bool
    var dateLogged: Date
    var date: Date

    // Relacionamentos
    var comments: [Comment]

    init(id: UUID = UUID(),
         userId: String,
         albumId: UUID,
         text: String,
         grade: Double,
         isLiked: Bool,
         isLogged: Bool,
         isSaved: Bool,
         dateLogged: Date,
         date: Date,
         comments: [Comment] = []) {

        self.id = id
        self.userId = userId
        self.albumId = albumId
        self.text = text
        self.grade = grade
        self.isLiked = isLiked
        self.isLogged = isLogged
        self.isSaved = isSaved
        self.dateLogged = dateLogged
        self.date = date
        self.comments = comments
    }
}
