//
//  DiscogsSearchResponse.swift
//  MusicBox
//
//  Created by Luca on 03/10/25.
//


import Foundation

struct DiscogsSearchResponse: Codable {
    let results: [DiscogsSearchResult]
}

struct DiscogsSearchResult: Codable, Identifiable {
    let id: Int
    let title: String
    let year: String?
    let type: String
    let thumb: String?
    let cover_image: String?
    let artist: String?

    var name: String {
        // Split: "Artist - Album Title" → ["Artist", "Album Title"]
        let parts = title.components(separatedBy: " - ")
        return parts.count > 1 ? parts[1] : title
    }

    var artistName: String {
        let parts = title.components(separatedBy: " - ")
        return parts.first ?? "Unknown"
    }
}

