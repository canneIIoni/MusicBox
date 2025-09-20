//
//  AlbumModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation

// MARK: - Album
class Album {
    var id: UUID
    var name: String
    var year: String
    var imageData: Data?
    var artistId: UUID

    // Relacionamentos
    var songs: [Song]
    var reviews: [Review]

    init(id: UUID = UUID(),
         name: String,
         year: String,
         imageData: Data? = nil,
         artistId: UUID,
         songs: [Song] = [],
         reviews: [Review] = []) {

        self.id = id
        self.name = name
        self.year = year
        self.imageData = imageData
        self.artistId = artistId
        self.songs = songs
        self.reviews = reviews
    }
}
