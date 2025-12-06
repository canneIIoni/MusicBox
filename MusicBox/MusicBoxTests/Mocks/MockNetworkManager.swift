//
//  MockNetworkManager.swift
//  MusicBoxTests
//
//  Created for testing purposes
//

import Foundation
@testable import MusicBox

/// Mock NetworkManager para simular respostas da API durante testes
class MockNetworkManager: NetworkManager {
    
    // MARK: - Properties
    
    var shouldSucceed: Bool = true
    var mockData: Data?
    var mockError: Error?
    var lastRequestedEndpoint: Endpoint?
    var lastRequestedHeaders: [String: String]?
    var requestCount: Int = 0
    
    // MARK: - Mock Response Setup
    
    /// Configura uma resposta de sucesso com dados mockados
    func setupSuccessResponse<T: Codable>(with data: T) {
        shouldSucceed = true
        mockError = nil
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        mockData = try? encoder.encode(data)
    }
    
    /// Configura uma resposta de erro
    func setupErrorResponse(_ error: Error) {
        shouldSucceed = false
        mockError = error
        mockData = nil
    }
    
    /// Configura dados JSON brutos como resposta
    func setupRawJSONResponse(_ jsonString: String) {
        shouldSucceed = true
        mockError = nil
        mockData = jsonString.data(using: .utf8)
    }
    
    /// Reseta o estado do mock
    func reset() {
        shouldSucceed = true
        mockData = nil
        mockError = nil
        lastRequestedEndpoint = nil
        lastRequestedHeaders = nil
        requestCount = 0
    }
    
    // MARK: - NetworkManager Protocol
    
    func request<T: Codable>(
        session: URLSession,
        _ endpoint: Endpoint,
        type: T.Type,
        headers: [String: String]?
    ) async throws -> T {
        
        // Armazena os parâmetros da requisição para verificação nos testes
        lastRequestedEndpoint = endpoint
        lastRequestedHeaders = headers
        requestCount += 1
        
        // Simula delay de rede
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        // Se deve falhar, lança o erro
        if !shouldSucceed {
            if let error = mockError {
                throw error
            } else {
                throw URLError(.badServerResponse)
            }
        }
        
        // Se deve ter sucesso, decodifica os dados mockados
        guard let data = mockData else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            throw error
        }
    }
}

