//
//  DiscogsServiceTests.swift
//  MusicBoxTests
//
//  Created for testing Discogs API service
//

import Testing
import Foundation
@testable import MusicBox

struct DiscogsServiceTests {
    
    // MARK: - Test Data Helpers
    
    static func createMockSearchResponse() -> DiscogsSearchResponse {
        let results = [
            DiscogsSearchResult(
                id: 12345,
                title: "Pink Floyd - The Dark Side of the Moon",
                year: "1973",
                type: "master",
                thumb: "https://example.com/thumb.jpg",
                cover_image: "https://example.com/cover.jpg",
                artist: "Pink Floyd"
            ),
            DiscogsSearchResult(
                id: 67890,
                title: "The Beatles - Abbey Road",
                year: "1969",
                type: "master",
                thumb: nil,
                cover_image: "https://example.com/abbey.jpg",
                artist: "The Beatles"
            )
        ]
        return DiscogsSearchResponse(results: results)
    }
    
    static func createMockMasterRelease() -> DiscogsMasterRelease {
        return DiscogsMasterRelease(
            title: "The Dark Side of the Moon",
            year: 1973,
            artists: [DiscogsArtist(name: "Pink Floyd")],
            genres: ["Rock", "Progressive Rock"],
            styles: ["Prog Rock", "Classic Rock"],
            images: [
                DiscogsImage(uri: "https://example.com/image.jpg", type: "primary")
            ],
            tracklist: [
                DiscogsTrack(title: "Speak to Me", duration: "1:30", position: "A1"),
                DiscogsTrack(title: "Breathe", duration: "2:43", position: "A2"),
                DiscogsTrack(title: "On the Run", duration: "3:35", position: "A3")
            ]
        )
    }
    
    // MARK: - Search Albums Tests
    
    @Test("Search albums with successful response")
    func testSearchAlbumsSuccess() async throws {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let mockResponse = Self.createMockSearchResponse()
        mockNetworkManager.setupSuccessResponse(with: mockResponse)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        // Act
        let results = try await discogsService.searchAlbums(query: "Pink Floyd")
        
        // Assert
        #expect(results.count == 2)
        #expect(results[0].id == 12345)
        #expect(results[0].name == "The Dark Side of the Moon")
        #expect(results[0].artistName == "Pink Floyd")
        #expect(results[1].id == 67890)
        
        // Verifica se o endpoint correto foi chamado
        if case .searchMasters(let query, _, _) = mockNetworkManager.lastRequestedEndpoint {
            #expect(query == "Pink Floyd")
        } else {
            Issue.record("Expected searchMasters endpoint")
        }
        
        // Verifica se os headers foram passados
        #expect(mockNetworkManager.lastRequestedHeaders != nil)
        #expect(mockNetworkManager.lastRequestedHeaders?["Authorization"] != nil)
    }
    
    @Test("Search albums returns empty array for empty response")
    func testSearchAlbumsEmptyResponse() async throws {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let emptyResponse = DiscogsSearchResponse(results: [])
        mockNetworkManager.setupSuccessResponse(with: emptyResponse)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        // Act
        let results = try await discogsService.searchAlbums(query: "Nonexistent Album")
        
        // Assert
        #expect(results.isEmpty)
    }
    
    @Test("Search albums handles network error")
    func testSearchAlbumsNetworkError() async throws {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let networkError = URLError(.notConnectedToInternet)
        mockNetworkManager.setupErrorResponse(networkError)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        // Act & Assert
        await #expect(throws: URLError.self) {
            try await discogsService.searchAlbums(query: "Test Query")
        }
    }
    
    @Test("Search albums handles server error")
    func testSearchAlbumsServerError() async throws {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let serverError = URLError(.badServerResponse)
        mockNetworkManager.setupErrorResponse(serverError)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        // Act & Assert
        await #expect(throws: URLError.self) {
            try await discogsService.searchAlbums(query: "Test Query")
        }
    }
    
    // MARK: - Fetch Master Release Tests
    
    @Test("Fetch master release with successful response")
    func testFetchMasterReleaseSuccess() async throws {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let mockRelease = Self.createMockMasterRelease()
        mockNetworkManager.setupSuccessResponse(with: mockRelease)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        let masterId = 12345
        
        // Act
        let release = try await discogsService.fetchMasterRelease(id: masterId)
        
        // Assert
        #expect(release.title == "The Dark Side of the Moon")
        #expect(release.year == 1973)
        #expect(release.artists.count == 1)
        #expect(release.artists[0].name == "Pink Floyd")
        #expect(release.genres.count == 2)
        #expect(release.tracklist.count == 3)
        #expect(release.tracklist[0].title == "Speak to Me")
        
        // Verifica se o endpoint correto foi chamado
        if case .masterRelease(let id) = mockNetworkManager.lastRequestedEndpoint {
            #expect(id == masterId)
        } else {
            Issue.record("Expected masterRelease endpoint")
        }
    }
    
    @Test("Fetch master release handles network error")
    func testFetchMasterReleaseNetworkError() async throws {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let networkError = URLError(.notConnectedToInternet)
        mockNetworkManager.setupErrorResponse(networkError)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        // Act & Assert
        await #expect(throws: URLError.self) {
            try await discogsService.fetchMasterRelease(id: 12345)
        }
    }
    
    @Test("Fetch master release parses optional fields correctly")
    func testFetchMasterReleaseOptionalFields() async throws {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let jsonString = """
        {
            "title": "Album Without Styles",
            "year": 2023,
            "artists": [{"name": "Artist"}],
            "genres": ["Rock"],
            "tracklist": [{"title": "Track 1", "position": "1"}]
        }
        """
        mockNetworkManager.setupRawJSONResponse(jsonString)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        // Act
        let release = try await discogsService.fetchMasterRelease(id: 123)
        
        // Assert - campos opcionais devem ser nil quando não presentes
        #expect(release.styles == nil)
        #expect(release.images == nil)
        #expect(release.tracklist[0].duration == nil)
    }
}

