//
//  DiscogsServiceEdgeCasesTests.swift
//  MusicBoxTests
//
//  Created for testing edge cases in DiscogsService
//

import Testing
import Foundation
@testable import MusicBox

struct DiscogsServiceEdgeCasesTests {
    
    @Test("Search albums with special characters in query")
    func testSearchAlbumsWithSpecialCharacters() async throws {
        let mockNetworkManager = MockNetworkManager()
        let emptyResponse = DiscogsSearchResponse(results: [])
        mockNetworkManager.setupSuccessResponse(with: emptyResponse)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        let query = "Mötley Crüe - Dr. Feelgood"
        let _ = try await discogsService.searchAlbums(query: query)
        
        // Verifica que a query foi passada corretamente
        if case .searchMasters(let searchQuery, _, _) = mockNetworkManager.lastRequestedEndpoint {
            #expect(searchQuery == query)
        }
    }
    
    @Test("Search albums with very long query")
    func testSearchAlbumsWithLongQuery() async throws {
        let mockNetworkManager = MockNetworkManager()
        let emptyResponse = DiscogsSearchResponse(results: [])
        mockNetworkManager.setupSuccessResponse(with: emptyResponse)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        let longQuery = String(repeating: "a", count: 500)
        let _ = try await discogsService.searchAlbums(query: longQuery)
        
        // Deve processar sem erro
        #expect(mockNetworkManager.requestCount == 1)
    }
    
    @Test("Fetch master release with zero ID")
    func testFetchMasterReleaseWithZeroID() async throws {
        let mockNetworkManager = MockNetworkManager()
        let mockRelease = DiscogsServiceTests.createMockMasterRelease()
        mockNetworkManager.setupSuccessResponse(with: mockRelease)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        let _ = try await discogsService.fetchMasterRelease(id: 0)
        
        if case .masterRelease(let id) = mockNetworkManager.lastRequestedEndpoint {
            #expect(id == 0)
        }
    }
    
    @Test("Fetch master release with large ID")
    func testFetchMasterReleaseWithLargeID() async throws {
        let mockNetworkManager = MockNetworkManager()
        let mockRelease = DiscogsServiceTests.createMockMasterRelease()
        mockNetworkManager.setupSuccessResponse(with: mockRelease)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        let largeID = Int.max
        let _ = try await discogsService.fetchMasterRelease(id: largeID)
        
        if case .masterRelease(let id) = mockNetworkManager.lastRequestedEndpoint {
            #expect(id == largeID)
        }
    }
    
    @Test("Multiple sequential searches")
    func testMultipleSequentialSearches() async throws {
        let mockNetworkManager = MockNetworkManager()
        let emptyResponse = DiscogsSearchResponse(results: [])
        mockNetworkManager.setupSuccessResponse(with: emptyResponse)
        
        let discogsService = DiscogsService(
            networkManager: mockNetworkManager,
            session: .shared
        )
        
        let _ = try await discogsService.searchAlbums(query: "First Query")
        let _ = try await discogsService.searchAlbums(query: "Second Query")
        let _ = try await discogsService.searchAlbums(query: "Third Query")
        
        #expect(mockNetworkManager.requestCount == 3)
    }
}

