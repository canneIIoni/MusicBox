//
//  NetworkingManager.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//


import Foundation
import OSLog

final class NetworkingManager: NetworkManager {
    
    public static let shared: NetworkingManager = .init()
    
    private init(){}
    
    func request<T: Codable>(session: URLSession,
                             _ endpoint: Endpoint,
                             type: T.Type,
                             headers: [String: String]? = nil) async throws -> T {
        
        guard let url = endpoint.url else {
            Logger.networkingManager.error("Failed to make a request due to invalid url")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        Logger.networkingManager.info("Making a request to: \(url)")
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse,
              (200...300) ~= response.statusCode else {
            let statusCode = (response as! HTTPURLResponse).statusCode
            Logger.networkingManager.error("Bad server response: \(statusCode)")
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let res = try decoder.decode(T.self, from: data)
        return res
    }
}

