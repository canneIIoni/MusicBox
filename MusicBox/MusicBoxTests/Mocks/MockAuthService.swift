//
//  MockAuthService.swift
//  MusicBoxTests
//
//  Created for testing purposes
//

import Foundation
@testable import MusicBox

/// Mock Authentication Service para testes
class MockAuthService: Authenticating,EmailPasswordHandling {

    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var errorMessage: String = ""
    var authenticationState: UserAuthState = .unauthenticated
    
    var mockAuthResult: AuthDataResultModel?
    var shouldThrowError: Bool = false
    var mockError: Error?
    
    var onAuthStateChanged: ((UserAuthState) -> Void)?
    
    init(mockAuthResult: AuthDataResultModel? = nil) {
        self.mockAuthResult = mockAuthResult
        if mockAuthResult != nil {
            self.authenticationState = .authenticated
        }
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        if shouldThrowError {
            throw mockError ?? URLError(.badServerResponse)
        }
        guard let result = mockAuthResult else {
            throw URLError(.badServerResponse)
        }
        return result
    }
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        if shouldThrowError {
            throw mockError ?? URLError(.badServerResponse)
        }
        return AuthDataResultModel(
            uid: "mock-user-id",
            email: email,
            photoUrl: nil,
            isAnonymous: false
        )
    }
    
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        if shouldThrowError {
            throw mockError ?? URLError(.badServerResponse)
        }
        let result = AuthDataResultModel(
            uid: "mock-user-id",
            email: email,
            photoUrl: nil,
            isAnonymous: false
        )
        authenticationState = .authenticated
        onAuthStateChanged?(.authenticated)
        return result
    }
    
    func signOut() throws {
        authenticationState = .unauthenticated
        onAuthStateChanged?(.unauthenticated)
    }
    
    func deleteAccount() async {
        authenticationState = .unauthenticated
        onAuthStateChanged?(.unauthenticated)
    }

    func resetPassword() async throws {

    }

    func updateEmail(to newEmail: String) async throws {

    }

    func updatePassword(to newPassword: String) async throws {
        
    }
}

