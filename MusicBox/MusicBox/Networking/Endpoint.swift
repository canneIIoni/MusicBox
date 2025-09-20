//
//  Endpoint.swift
//  NanoChallenge07
//
//   Created by Luca Lacerda on 20/09/25.
//

import Foundation

enum Endpoint {
}

extension Endpoint {
    var host: String {
        return ""
    }
    
    var path: String {
        return ""
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}

extension Endpoint {
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
