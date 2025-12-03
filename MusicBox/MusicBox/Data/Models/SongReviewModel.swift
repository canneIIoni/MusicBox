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
    var songID: String        // The Spotify/Discogs track ID
    var title: String
    var trackNumber: Int
    var grade: Double         // 0–5
    var reviewText: String
    var isLiked = false
    
    init(songID: String, title: String, trackNumber: Int, grade: Double, reviewText: String) {
        self.songID = songID
        self.title = title
        self.trackNumber = trackNumber
        self.grade = min(max(grade, 0), 5)
        self.reviewText = reviewText
    }
}
