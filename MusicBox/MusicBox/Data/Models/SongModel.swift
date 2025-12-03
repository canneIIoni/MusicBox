//
//  SongModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import SwiftData
import Foundation

@Model
class Song {
    @Attribute(.unique) var id: String // Spotify/Discogs track ID
    var title: String
    var trackNumber: Int
    var duration: Int? // seconds

    @Relationship(inverse: \Album.songs)
    var album: Album

    init(id: String, title: String, trackNumber: Int, duration: Int? = nil, album: Album) {
        self.id = id
        self.title = title
        self.trackNumber = trackNumber
        self.duration = duration
        self.album = album
    }
}

