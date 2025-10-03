//
//  DiscogsService.swift
//  MusicBox
//
//  Created by Luca on 03/10/25.
//

import Foundation

// MARK: - Networking Abstraction

protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}

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
    private let baseURL = "https://api.discogs.com"
    private let token = "SCTuZavpfmnVCmsVaDPajUmnoVCJrlRViwRFPuvE"
    private let session: NetworkSession

    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    func searchAlbums(query: String) async throws -> [DiscogsSearchResult] {
        var components = URLComponents(string: "\(baseURL)/database/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "master")
        ]

        let url = components.url!
        var request = URLRequest(url: url)
        request.setValue("Discogs token=\(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        let decoded = try JSONDecoder().decode(DiscogsSearchResponse.self, from: data)
        return decoded.results
    }

    func fetchMasterRelease(id: Int) async throws -> DiscogsMasterRelease {
        let url = URL(string: "\(baseURL)/masters/\(id)")!
        var request = URLRequest(url: url)
        request.setValue("Discogs token=\(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(DiscogsMasterRelease.self, from: data)
    }
}




