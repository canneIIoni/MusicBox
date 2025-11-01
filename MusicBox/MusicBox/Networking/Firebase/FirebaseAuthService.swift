//
//  FirebaseAuthService.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//

//
//  AuthenticationService.swift
//  BetterHabits
//
//  Created by Mateus Martins Pires on 28/02/25.
//

import Foundation
import FirebaseAuth

enum UserAuthState {
    case authenticated
    case unauthenticated
}

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}

protocol Authenticating {
    
    var email: String { get set }
    var password: String { get set }
    var confirmPassword: String { get set }
    var errorMessage: String { get set }
        
    var authenticationState: UserAuthState { get set }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel
    
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel
    
    func signOut() throws
    
    func deleteAccount() async
    
    var onAuthStateChanged: ((UserAuthState) -> Void)? { get set }

}

protocol EmailPasswordHandling {
    func resetPassword() async throws
    func updateEmail(to newEmail: String) async throws
    func updatePassword(to newPassword: String) async throws
}


class FirebaseAuthService: Authenticating, ObservableObject {
    
    var email: String = ""
    
    var password: String = ""
    
    var confirmPassword: String = ""
    
    var errorMessage: String = ""
    
    @Published var authenticationState: UserAuthState = .unauthenticated
    
    var onAuthStateChanged: ((UserAuthState) -> Void)?
    
    var user: User?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    
    init() {
        registerAuthStateHandler()
    }
    
    // Porque ele passa duas vezes aqui?
    func registerAuthStateHandler() {
        if authStateHandle == nil {
            authStateHandle = Auth.auth().addStateDidChangeListener({ auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.onAuthStateChanged?(self.authenticationState)
            })
        }
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    // I not always want to retrieve the AuthDataResultModel
    
#warning("Save user with KeyChain")
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            return AuthDataResultModel(user: authResult.user)
    }
    
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
#warning("Must have a alert before doing this action")
#warning("Must delete the auth user and the db user")

    func deleteAccount() async {
        do {
            try await user?.delete()
        }
        catch {
            errorMessage = error.localizedDescription

        }
    }
}

extension FirebaseAuthService: EmailPasswordHandling {
    
    // When user is not logged in
    func resetPassword() async throws {
        
        let authUser = try getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updateEmail(to newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }
    
    func updatePassword(to newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: newPassword)
    }
}
