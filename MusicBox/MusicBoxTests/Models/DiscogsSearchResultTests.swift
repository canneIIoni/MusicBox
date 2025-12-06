//
//  DiscogsSearchResultTests.swift
//  MusicBoxTests
//
//  Created for testing DiscogsSearchResult computed properties
//

import Testing
@testable import MusicBox

struct DiscogsSearchResultTests {
    
    @Test("Name property extracts album name from title")
    func testNamePropertyExtractsAlbumName() {
        let result = DiscogsSearchResult(
            id: 1,
            title: "Pink Floyd - The Dark Side of the Moon",
            year: "1973",
            type: "master",
            thumb: nil,
            cover_image: nil,
            artist: nil
        )
        
        #expect(result.name == "The Dark Side of the Moon")
    }
    
    @Test("Name property returns full title when no separator exists")
    func testNamePropertyReturnsFullTitleWithoutSeparator() {
        let result = DiscogsSearchResult(
            id: 2,
            title: "Unknown Format Album",
            year: "2020",
            type: "master",
            thumb: nil,
            cover_image: nil,
            artist: nil
        )
        
        #expect(result.name == "Unknown Format Album")
    }
    
    @Test("ArtistName property extracts artist from title")
    func testArtistNamePropertyExtractsArtist() {
        let result = DiscogsSearchResult(
            id: 3,
            title: "The Beatles - Abbey Road",
            year: "1969",
            type: "master",
            thumb: nil,
            cover_image: nil,
            artist: nil
        )
        
        #expect(result.artistName == "The Beatles")
    }

    
    @Test("DiscogsSearchResult is Identifiable")
    func testDiscogsSearchResultIsIdentifiable() {
        let result = DiscogsSearchResult(
            id: 123,
            title: "Test - Album",
            year: "2020",
            type: "master",
            thumb: nil,
            cover_image: nil,
            artist: nil
        )
        
        // Verifica que tem id (requisito do Identifiable)
        #expect(result.id == 123)
    }
    
    @Test("DiscogsSearchResult handles optional fields")
    func testDiscogsSearchResultOptionalFields() {
        let resultWithAllFields = DiscogsSearchResult(
            id: 1,
            title: "Test - Album",
            year: "2020",
            type: "master",
            thumb: "https://example.com/thumb.jpg",
            cover_image: "https://example.com/cover.jpg",
            artist: "Test Artist"
        )
        
        #expect(resultWithAllFields.thumb != nil)
        #expect(resultWithAllFields.cover_image != nil)
        #expect(resultWithAllFields.artist != nil)
        
        let resultWithoutOptionalFields = DiscogsSearchResult(
            id: 2,
            title: "Test - Album",
            year: nil,
            type: "master",
            thumb: nil,
            cover_image: nil,
            artist: nil
        )
        
        #expect(resultWithoutOptionalFields.year == nil)
        #expect(resultWithoutOptionalFields.thumb == nil)
        #expect(resultWithoutOptionalFields.cover_image == nil)
    }
}

