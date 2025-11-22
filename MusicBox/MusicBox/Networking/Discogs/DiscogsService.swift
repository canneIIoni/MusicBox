//
//  DiscogsService.swift
//  MusicBox
//
//  Created by Luca on 03/10/25.
//

import Foundation

// MARK: - Discogs Models

struct DiscogsMasterRelease: Codable {
    let title: String
    let year: Int
    let artists: [DiscogsArtist]
    let genres: [String]
    let styles: [String]?
    let images: [DiscogsImage]?
    let tracklist: [DiscogsTrack]
}

struct DiscogsArtist: Codable {
    let name: String
}

struct DiscogsImage: Codable {
    let uri: String
    let type: String
}

struct DiscogsTrack: Codable {
    let title: String
    let duration: String?
    let position: String?
}

// MARK: - Discogs Service

class DiscogsService {
    private let networkManager: NetworkManager
    private let session: URLSession

    init(networkManager: NetworkManager = NetworkingManager.shared, session: URLSession = .shared) {
        self.networkManager = networkManager
        self.session = session
    }

    func searchAlbums(query: String) async throws -> [DiscogsSearchResult] {
        let endpoint = Endpoint.searchMasters(query: query, page: nil, perPage: nil)
        let response = try await networkManager.request(
            session: session,
            endpoint,
            type: DiscogsSearchResponse.self,
            headers: APIConfiguration.discogsHeaders
        )
        return response.results
    }

    func fetchMasterRelease(id: Int) async throws -> DiscogsMasterRelease {
        let endpoint = Endpoint.masterRelease(id: id)
        return try await networkManager.request(
            session: session,
            endpoint,
            type: DiscogsMasterRelease.self,
            headers: APIConfiguration.discogsHeaders
        )
    }
}




