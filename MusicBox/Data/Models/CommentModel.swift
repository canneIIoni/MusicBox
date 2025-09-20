//
//  CommentModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation


// MARK: - Comment
class Comment {
    var id: UUID
    var userId: String
    var reviewId: UUID
    var text: String
    var date: Date

    init(id: UUID = UUID(),
         userId: String,
         reviewId: UUID,
         text: String,
         date: Date) {

        self.id = id
        self.userId = userId
        self.reviewId = reviewId
        self.text = text
        self.date = date
    }
}
