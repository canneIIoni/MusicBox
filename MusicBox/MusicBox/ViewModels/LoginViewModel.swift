//
//  LoginViewModel.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    
    var authenticationService: (Authenticating & EmailPasswordHandling)
    let userManager: UserFirestoreService
    
    @Published var email = ""
    @Published var password = ""
    @Published var newPassword = ""
    
    @Published var authenticationState: UserAuthState = .unauthenticated
    @Published var errorMessage: String?
    @Published var isLoading = false

    init(authenticationService: (Authenticating & EmailPasswordHandling), userManager: UserFirestoreService) {
        self.authenticationService = authenticationService
        self.userManager = userManager
        
        observeAuthState()
    }
    
    // Adicionando listener para o estado de autenticação:
    func observeAuthState() {
        authenticationService.onAuthStateChanged = { [weak self] state in
            guard let self = self else { return }
            Task { @MainActor in
                self.authenticationState = state
            }
        }
    }
    
    func signUpWithEmail() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let returnedData = try await authenticationService.createUser(email: email, password: password)
                print("Successfully signed up: \(returnedData)")
                
                // Usando o inicializador que aceita AuthDataResultModel
                let user = DBUser(auth: returnedData)
                
                // UserManager must create a User in FireStore
                try await userManager.createNewUser(user: user)
                
                await MainActor.run {
                    isLoading = false
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = handleAuthError(error)
                    print("❌ Sign up error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func signInWithEmail() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let returnedData = try await authenticationService.signInUser(email: email, password: password)
                print("Successfully signed in: \(returnedData)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = handleAuthError(error)
                    print("❌ Sign in error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleAuthError(_ error: Error) -> String {
        return "Firebase authentication error. Please check your Firebase configuration."
    }
    
    func resetPassword() {
        Task {
            do {
                try await authenticationService.resetPassword()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try authenticationService.signOut()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updatePassword() {
        guard !password.isEmpty, !newPassword.isEmpty else {
            print("Not old password or new password found.")
            return
        }
        
        Task {
            do {
                try await authenticationService.updatePassword(to: newPassword)
            } catch {
                
            }
        }
    }
    
    // MARK: - Debug Methods
    
    func loginWithHardcodedUser() {
        email = DebugConfig.hardcodedEmail
        password = DebugConfig.hardcodedPassword
        
        isLoading = true
        errorMessage = nil
        
        // Bypass Firebase - just set as authenticated for debug mode
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            await MainActor.run {
                // Set authentication state directly without Firebase
                if let firebaseAuthService = authenticationService as? FirebaseAuthService {
                    firebaseAuthService.setAuthenticatedForDebug(email: DebugConfig.hardcodedEmail)
                }
                
                // Update local state (will also be updated via observeAuthState callback)
                isLoading = false
                errorMessage = nil
                
                print("✅ Debug user logged in (bypassing Firebase)")
            }
        }
    }
}
