//
//  RegisterViewModel.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

import Foundation

class RegisterViewModel: ObservableObject {
    
    var authenticationService: (Authenticating & EmailPasswordHandling)
    let userManager: UserFirestoreService
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    @Published var authenticationState: UserAuthState = .unauthenticated
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(authenticationService: (Authenticating & EmailPasswordHandling), userManager: UserFirestoreService) {
        self.authenticationService = authenticationService
        self.userManager = userManager
        
        observeAuthState()
    }
    
    func observeAuthState() {
        authenticationService.onAuthStateChanged = { [weak self] state in
            guard let self = self else { return }
            self.authenticationState = state
        }
    }
    
    var isEmailValid: Bool {
        !email.isEmpty && email.contains("@") && email.contains(".")
    }
    
    var isPasswordValid: Bool {
        password.count >= 6
    }
    
    var doPasswordsMatch: Bool {
        password == confirmPassword || confirmPassword.isEmpty
    }
    
    var canSignUp: Bool {
        isEmailValid && 
        isPasswordValid && 
        doPasswordsMatch && 
        !isLoading
    }
    
    func signUpWithEmail() {
        guard canSignUp else {
            errorMessage = "Please fill all fields correctly"
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
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

