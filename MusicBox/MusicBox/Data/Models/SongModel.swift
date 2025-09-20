//
//  SongModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation

// MARK: - Song
class Song {
    var id: UUID
    var title: String
    var trackNumber: Int
    var albumId: UUID

    init(id: UUID = UUID(),
         title: String,
         trackNumber: Int,
         albumId: UUID) {

        self.id = id
        self.title = title
        self.trackNumber = trackNumber
        self.albumId = albumId
    }
}
