//
//  MockUserFirestoreService.swift
//  MusicBoxTests
//
//  Created for testing purposes
//

import Foundation
@testable import MusicBox

/// Mock UserFirestoreService para testes
/// Nota: Como UserFirestoreService não é open, criamos uma classe separada
/// que pode ser usada nos testes através de type casting ou protocolo
class MockUserFirestoreService {
    
    var mockUser: DBUser?
    var shouldThrowError: Bool = false
    var mockError: Error?
    var createUserCalled = false
    var getUserCalled = false
    
    init(mockUser: DBUser? = nil) {
        self.mockUser = mockUser
    }
    
    func getUser(userID: String) async throws -> DBUser {
        getUserCalled = true
        
        if shouldThrowError {
            throw mockError ?? URLError(.badServerResponse)
        }
        
        guard let user = mockUser else {
            throw URLError(.badServerResponse)
        }
        
        return user
    }
    
    func createNewUser(user: DBUser) async throws {
        createUserCalled = true
        
        if shouldThrowError {
            throw mockError ?? URLError(.badServerResponse)
        }
        
        mockUser = user
    }
    
    func updateUserPremiumStatus(userID: String, isPremium: Bool) async throws {
        if shouldThrowError {
            throw mockError ?? URLError(.badServerResponse)
        }
        
        mockUser?.isPremium = isPremium
    }
}

