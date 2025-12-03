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
    
    // Direct initializer for debug mode
    init(uid: String, email: String?, photoUrl: String? = nil, isAnonymous: Bool = false) {
        self.uid = uid
        self.email = email
        self.photoUrl = photoUrl
        self.isAnonymous = isAnonymous
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
    
    // MARK: - UI Test Flag
    // When set to true: the app ALWAYS starts authenticated
    static var forceAuthenticatedForUITests = false

    // MARK: - Stored Properties
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var errorMessage: String = ""

    @Published var authenticationState: UserAuthState = .unauthenticated
    var onAuthStateChanged: ((UserAuthState) -> Void)?

    var user: User?
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Debug Mode (Firebase bypass)
    private var isDebugMode = false
    private var debugUserId = "debug-user-id"
    private var debugEmail = DebugConfig.hardcodedEmail

    
    // MARK: - Init

    init() {

        // 🚀 UI TEST MODE: bypass Firebase & start authenticated
        if Self.forceAuthenticatedForUITests {
            Task { @MainActor in
                self.isDebugMode = true
                self.debugUserId = "uitest-user-id"
                self.debugEmail = "uitest@example.com"
                self.authenticationState = .authenticated
                self.onAuthStateChanged?(.authenticated)
                print("🚀 UI Tests: automatically authenticated")
            }
            return
        }

        // Normal app launch
        registerAuthStateHandler()
    }
    
    // MARK: - Firebase Listener
    func registerAuthStateHandler() {
        if authStateHandle == nil {
            authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.onAuthStateChanged?(self.authenticationState)
            }
        }
    }

    // MARK: - Debug / UI Test Authentication
    func setAuthenticatedForDebug(
        userId: String = "debug-user-id",
        email: String = DebugConfig.hardcodedEmail
    ) {
        Task { @MainActor in
            self.isDebugMode = true
            self.debugUserId = userId
            self.debugEmail = email
            self.authenticationState = .authenticated
            self.onAuthStateChanged?(.authenticated)
            print("✅ Debug mode: Authenticated without Firebase")
        }
    }

    // MARK: - Get Current User
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        
        // Debug / UI test mode
        if isDebugMode && authenticationState == .authenticated {
            return AuthDataResultModel(
                uid: debugUserId,
                email: debugEmail
            )
        }
        
        // Normal Firebase mode
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }

    // MARK: - Auth Methods

    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: result.user)
    }

    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: result.user)
    }

    func signOut() throws {
        if isDebugMode {
            Task { @MainActor in
                self.isDebugMode = false
                self.authenticationState = .unauthenticated
                self.onAuthStateChanged?(.unauthenticated)
                print("🔶 Debug user signed out")
            }
            return
        }
        
        try Auth.auth().signOut()
    }

    func deleteAccount() async {
        do {
            try await user?.delete()
        } catch {
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
