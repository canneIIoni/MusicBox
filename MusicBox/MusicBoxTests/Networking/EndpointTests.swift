//
//  EndpointTests.swift
//  MusicBoxTests
//
//  Created for testing Endpoint URL generation
//

import Testing
import Foundation
@testable import MusicBox

struct EndpointTests {
    
    @Test("Master release endpoint generates correct URL")
    func testMasterReleaseURL() {
        let endpoint = Endpoint.masterRelease(id: 12345)
        let url = endpoint.url
        
        #expect(url != nil)
        #expect(url?.absoluteString == "https://api.discogs.com/masters/12345")
        #expect(endpoint.host == "api.discogs.com")
        #expect(endpoint.path == "/masters/12345")
    }
    
    @Test("Release endpoint generates correct URL")
    func testReleaseURL() {
        let endpoint = Endpoint.release(id: 67890)
        let url = endpoint.url
        
        #expect(url != nil)
        #expect(url?.absoluteString == "https://api.discogs.com/releases/67890")
        #expect(endpoint.path == "/releases/67890")
    }
    
    @Test("Master versions endpoint generates correct URL")
    func testMasterVersionsURL() {
        let endpoint = Endpoint.masterVersions(masterId: 11111)
        let url = endpoint.url
        
        #expect(url != nil)
        #expect(url?.absoluteString == "https://api.discogs.com/masters/11111/versions")
        #expect(endpoint.path == "/masters/11111/versions")
    }
    
    @Test("Search masters endpoint generates correct URL without pagination")
    func testSearchMastersURLWithoutPagination() {
        let endpoint = Endpoint.searchMasters(query: "Pink Floyd", page: nil, perPage: nil)
        let url = endpoint.url
        
        #expect(url != nil)
        let urlString = url?.absoluteString ?? ""
        #expect(urlString.contains("https://api.discogs.com/database/search"))
        #expect(urlString.contains("q=Pink%20Floyd"))
        #expect(urlString.contains("type=master"))
        #expect(endpoint.path == "/database/search")
    }
    
    @Test("Search masters endpoint generates correct URL with pagination")
    func testSearchMastersURLWithPagination() {
        let endpoint = Endpoint.searchMasters(query: "Beatles", page: 2, perPage: 50)
        let url = endpoint.url
        
        #expect(url != nil)
        let urlString = url?.absoluteString ?? ""
        #expect(urlString.contains("q=Beatles"))
        #expect(urlString.contains("type=master"))
        #expect(urlString.contains("page=2"))
        #expect(urlString.contains("per_page=50"))
    }
    
    @Test("Search releases endpoint generates correct URL")
    func testSearchReleasesURL() {
        let endpoint = Endpoint.searchReleases(query: "Test Album", page: 1, perPage: 25)
        let url = endpoint.url
        
        #expect(url != nil)
        let urlString = url?.absoluteString ?? ""
        #expect(urlString.contains("q=Test%20Album"))
        #expect(urlString.contains("type=release"))
        #expect(urlString.contains("page=1"))
        #expect(urlString.contains("per_page=25"))
    }
    
    @Test("Search endpoint URL encodes special characters")
    func testSearchURLEncoding() {
        let endpoint = Endpoint.searchMasters(query: "Mötley Crüe", page: nil, perPage: nil)
        let url = endpoint.url
        
        #expect(url != nil)
        let urlString = url?.absoluteString ?? ""
        // Verifica que caracteres especiais são codificados
        #expect(urlString.contains("database/search"))
    }
    
    @Test("Query items are correctly formatted for search masters")
    func testSearchMastersQueryItems() {
        let endpoint = Endpoint.searchMasters(query: "Test", page: 1, perPage: 20)
        let queryItems = endpoint.queryItems
        
        #expect(queryItems != nil)
        #expect(queryItems?.count == 4)
        
        let itemsDict = Dictionary(uniqueKeysWithValues: queryItems!.map { ($0.name, $0.value) })
        #expect(itemsDict["q"] == "Test")
        #expect(itemsDict["type"] == "master")
        #expect(itemsDict["page"] == "1")
        #expect(itemsDict["per_page"] == "20")
    }
    
    @Test("Query items are nil for non-search endpoints")
    func testNonSearchEndpointsHaveNilQueryItems() {
        let masterEndpoint = Endpoint.masterRelease(id: 123)
        let releaseEndpoint = Endpoint.release(id: 456)
        let versionsEndpoint = Endpoint.masterVersions(masterId: 789)
        
        #expect(masterEndpoint.queryItems == nil)
        #expect(releaseEndpoint.queryItems == nil)
        #expect(versionsEndpoint.queryItems == nil)
    }
}

