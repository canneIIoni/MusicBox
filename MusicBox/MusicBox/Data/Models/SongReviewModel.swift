//
//  SongReview.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//

import SwiftData
import Foundation

@Model
class SongReview {
    var id: UUID = UUID()
    var grade: Double         // 0–5
    var reviewText: String
    var isLiked = false
    
    // Relationship to the actual Song
    @Relationship(inverse: \Song.songReviews)
    var song: Song
    
    // Computed properties for convenience
    var title: String {
        song.title
    }
    
    var trackNumber: Int {
        song.trackNumber
    }
    
    var duration: Int? {
        song.duration
    }
    
    var artist: String {
        song.album.artist
    }
    
    init(song: Song, grade: Double = 0.0, reviewText: String = "", isLiked: Bool = false) {
        self.song = song
        self.grade = min(max(grade, 0), 5)
        self.reviewText = reviewText
        self.isLiked = isLiked
    }
}
