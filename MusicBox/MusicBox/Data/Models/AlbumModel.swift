//
//  AlbumModel.swift
//  MusicBox
//
//  Created by Luca on 29/09/25.
//

import SwiftData
import Foundation
import UIKit

@Model
public class Album {
    @Attribute(.unique) public var id: String      // Spotify or Discogs ID
    var name: String
    var artist: String
    var year: String?
    var imageData: Data?

    @Relationship(deleteRule: .cascade)
    var reviews: [AlbumReview] = []

    @Relationship(deleteRule: .cascade)
    var songs: [Song] = []

    init(id: String, name: String, artist: String, year: String? = nil, image: UIImage? = nil) {
        self.id = id
        self.name = name
        self.artist = artist
        self.year = year
        self.imageData = image?.jpegData(compressionQuality: 0.8)
    }

    var albumImage: UIImage? {
        imageData.flatMap { UIImage(data: $0) }
    }
}




