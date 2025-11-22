//
//  NetworkManager.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import Foundation

protocol NetworkManager {
    func request<T: Codable>(session: URLSession,
                             _ endpoint: Endpoint,
                             type: T.Type,
                             headers: [String: String]?) async throws -> T
}
