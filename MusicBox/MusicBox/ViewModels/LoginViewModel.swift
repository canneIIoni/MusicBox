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

    // MARK: - Auto Login Toggle
    @Published var autoLoginEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoLoginEnabled, forKey: "autoLoginEnabled")
        }
    }

    init(authenticationService: (Authenticating & EmailPasswordHandling), userManager: UserFirestoreService) {
        self.authenticationService = authenticationService
        self.userManager = userManager

        // Load toggle value
        self.autoLoginEnabled = UserDefaults.standard.bool(forKey: "autoLoginEnabled")

        observeAuthState()

        // 🔧 FIXED AUTO-LOGIN BEHAVIOR
        DispatchQueue.main.async {
            if self.autoLoginEnabled {
                self.tryAutoLoginIfSessionExists()
            } else {
                print("🔒 Auto-login disabled — session ignored")
                self.authenticationState = .unauthenticated
            }
        }

        // UI Test auto-login
        if ProcessInfo.processInfo.arguments.contains("--ui-test-debug-login") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.loginWithHardcodedUser()
            }
        }
    }

    // MARK: - Auto Login Handling
    private func tryAutoLoginIfSessionExists() {
        guard autoLoginEnabled else {
            print("🔒 Auto-login disabled")
            return
        }

        if let firebaseUser = Auth.auth().currentUser {
            print("🔄 Firebase session found for: \(firebaseUser.email ?? "unknown")")
            self.authenticationState = .authenticated
        } else {
            print("❌ No Firebase session found — user must log in")
        }
    }

    // MARK: - Observe Authentication Changes
    func observeAuthState() {
        authenticationService.onAuthStateChanged = { [weak self] state in
            guard let self = self else { return }

            Task { @MainActor in
                // ❌ Do NOT auto-authenticate when toggle is OFF
                if !self.autoLoginEnabled && state == .authenticated {
                    print("🚫 Firebase session found but auto-login is OFF — staying on login screen")
                    self.authenticationState = .unauthenticated
                    return
                }

                // ✅ Normal behavior when toggle is ON
                self.authenticationState = state
            }
        }
    }


    // MARK: - Sign Up
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

                let user = DBUser(auth: returnedData)
                try await userManager.createNewUser(user: user)

                await MainActor.run {
                    isLoading = false
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = handleAuthError(error)
                }
            }
        }
    }

    // MARK: - Sign In
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
                }
            }
        }
    }

    private func handleAuthError(_ error: Error) -> String {
        return "Firebase authentication error. Please check your Firebase configuration."
    }

    // MARK: - Password Reset
    func resetPassword() {
        Task {
            do {
                try await authenticationService.resetPassword()
            } catch { print(error) }
        }
    }

    func signOut() {
        Task { try? authenticationService.signOut() }
    }

    func updatePassword() {
        guard !password.isEmpty, !newPassword.isEmpty else { return }
        Task { try? await authenticationService.updatePassword(to: newPassword) }
    }

    // MARK: - Debug Login
    func loginWithHardcodedUser() {
        email = DebugConfig.hardcodedEmail
        password = DebugConfig.hardcodedPassword

        isLoading = true
        errorMessage = nil

        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s delay
            await MainActor.run {
                if let firebaseAuth = authenticationService as? FirebaseAuthService {
                    firebaseAuth.setAuthenticatedForDebug(email: DebugConfig.hardcodedEmail)
                }

                isLoading = false
                errorMessage = nil

                print("✅ Debug user logged in (UI Test Mode)")
            }
        }
    }
}
