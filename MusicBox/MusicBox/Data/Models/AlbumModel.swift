//
//  AlbumModel.swift
//  Statik
//
//  Created by Luca on 28/02/25.
//

import SwiftData
import Foundation
import UIKit

@Model
class Album {
    var id: UUID = UUID()
    var name: String
    var artist: String
    var year: String?
    var review: String
    var isLiked: Bool
    var grade: Double
    var imageData: Data?
    var isLogged: Bool = false
    var dateLogged: Date? = nil
    var isSaved: Bool = false
    @Relationship(deleteRule: .cascade) var songs: [Song] = []

    init(name: String, artist: String, year: String, review: String, isLiked: Bool, grade: Double, image: UIImage? = nil, songs: [Song] = [], dateLogged: Date) {
        self.name = name
        self.artist = artist
        self.year = year
        self.review = review
        self.isLiked = isLiked
        self.grade = min(max(grade, 0), 5) // Ensure grade is between 0-5
        self.imageData = image?.jpegData(compressionQuality: 0.8)
        self.songs = songs
        self.dateLogged = dateLogged
    }


    var albumImage: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }
}


