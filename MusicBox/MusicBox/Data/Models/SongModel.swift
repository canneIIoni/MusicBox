//
//  SongModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation

// MARK: - Song
struct Song: Codable {
    var id: UUID
    var title: String
    var trackNumber: Int
    var albumId: UUID
}
