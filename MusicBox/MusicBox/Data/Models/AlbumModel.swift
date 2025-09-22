//
//  AlbumModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation

struct SearchResponse: Codable {
    let pagination: Pagination
    let results: [Album]
}

struct Pagination: Codable {
    let page: Int
    let pages: Int
    let per_page: Int
    let items: Int
}

// MARK: - Album
struct Album: Codable {
    var id: Float
    var name: String
    var year: String
    var imageData: Data?
    var artistId: UUID

    // Relacionamentos
    var songs: [Song]
    var reviews: [Review]
}
