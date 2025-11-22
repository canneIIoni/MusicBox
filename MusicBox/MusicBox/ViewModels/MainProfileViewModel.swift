//
//  MainProfileViewModel.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//

import Foundation
import FirebaseAuth

class MainProfileViewModel: ObservableObject {
    let authenticationService: Authenticating
    let userManager: UserFirestoreService
    
    @Published private(set) var user: DBUser? = nil
    
    init(authenticationService: Authenticating, userManager: UserFirestoreService) {
        self.authenticationService = authenticationService
        self.userManager = userManager
    }
    
    func loadCurrentUser() async throws {
        let authResult = try authenticationService.getAuthenticatedUser()
        
        // In debug mode, create a mock user without Firestore
        if let firebaseAuthService = authenticationService as? FirebaseAuthService,
           authResult.uid == "debug-user-id" {
            self.user = DBUser(
                userId: authResult.uid,
                username: nil,
                email: authResult.email,
                isAnonymous: false,
                photoUrl: nil,
                dateCreated: Date(),
                isPremium: false
            )
            return
        }
        
        // Normal flow - load from Firestore
        self.user = try await userManager.getUser(userID: authResult.uid)
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        
        Task {
            try await userManager.updateUserPremiumStatus(userID: user.userId, isPremium: !currentValue)
            self.user = try await userManager.getUser(userID: user.userId)
        }
    }
    
    func signOut() {
        Task {
            try authenticationService.signOut()
        }
    }
    
    func resetPassword() {
        Task {
            do {
                guard let email = user?.email else {
                    print("❌ No email found for password reset")
                    return
                }
                
                // Send password reset email via Firebase Auth
                try await Auth.auth().sendPasswordReset(withEmail: email)
                print("✅ Password reset email sent to: \(email)")
            } catch {
                print("❌ Reset password error: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAccount() {
        Task {
            await authenticationService.deleteAccount()
            try? authenticationService.signOut()
        }
    }
}

