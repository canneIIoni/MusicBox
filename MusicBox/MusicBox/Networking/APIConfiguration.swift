//
//  APIConfiguration.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

import Foundation

struct APIConfiguration {
    
    // MARK: - Discogs API
    
    static let discogsToken = "SCTuZavpfmnVCmsVaDPajUmnoVCJrlRViwRFPuvE"
    
    static var discogsHeaders: [String: String] {
        return ["Authorization": "Discogs token=\(discogsToken)"]
    }
    
    // MARK: - Base URLs
    
    static let discogsBaseURL = "https://api.discogs.com"
}

