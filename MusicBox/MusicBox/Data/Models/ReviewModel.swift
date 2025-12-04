//
//  ReviewModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import SwiftData
import Foundation

@Model
public class AlbumReview {
    public var id: UUID = UUID()
    var userId: String
    var username: String?
    var text: String
    var rating: Double        // Full album rating (can be computed later)
    var date: Date
    var isLiked: Bool
    var isLogged = false

    @Relationship(deleteRule: .cascade)
    var songReviews: [SongReview] = []

    @Relationship(inverse: \Album.reviews)
    var album: Album

    init(
        userId: String,
        username: String? = nil,
        text: String,
        rating: Double,
        date: Date,
        album: Album,
        isLiked: Bool
    ) {
        self.userId = userId
        self.username = username
        self.text = text
        self.rating = rating
        self.date = date
        self.album = album
        self.isLiked = isLiked
    }

    /// OPTIONAL: Automatic album rating based on song ratings
    var computedAlbumRating: Double {
        guard !songReviews.isEmpty else { return rating }
        let avg = songReviews.map { $0.grade }.reduce(0, +) / Double(songReviews.count)
        return avg
    }
}

