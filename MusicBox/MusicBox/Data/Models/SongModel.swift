//
//  SongModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import SwiftData
import Foundation
import UIKit

@Model
class Song {
    var id: UUID = UUID()
    var title: String
    var isLiked: Bool
    var grade: Double
    var review: String
    var trackNumber: Int

    init(title: String, isLiked: Bool, grade: Double, review: String, trackNumber: Int) {
        self.title = title
        self.isLiked = isLiked
        self.grade = min(max(grade, 0), 5) // Ensuring grade is between 0-5
        self.review = review
        self.trackNumber = trackNumber
    }
}
