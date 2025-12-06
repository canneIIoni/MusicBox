//
//  APIConfigurationTests.swift
//  MusicBoxTests
//
//  Created for testing APIConfiguration
//

import Testing
@testable import MusicBox

struct APIConfigurationTests {
    
    @Test("Discogs base URL is correct")
    func testDiscogsBaseURL() {
        #expect(APIConfiguration.discogsBaseURL == "https://api.discogs.com")
    }
    
    @Test("Discogs headers contain authorization")
    func testDiscogsHeadersContainAuthorization() {
        let headers = APIConfiguration.discogsHeaders
        
        #expect(headers["Authorization"] != nil)
        #expect(headers["Authorization"]?.contains("Discogs token=") == true)
    }
    
    @Test("Discogs headers contain token")
    func testDiscogsHeadersContainToken() {
        let headers = APIConfiguration.discogsHeaders
        let authHeader = headers["Authorization"] ?? ""
        
        // Verifica que contém o token (não vazio após "token=")
        let tokenPart = authHeader.components(separatedBy: "token=").last ?? ""
        #expect(!tokenPart.isEmpty)
    }
}

