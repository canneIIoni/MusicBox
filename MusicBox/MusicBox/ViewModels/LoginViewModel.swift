//
//  LoginViewModel.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//

import Foundation

class LoginViewModel: ObservableObject {
    
    var authenticationService: (Authenticating & EmailPasswordHandling)
    let userManager: UserFirestoreService
    
    @Published var email = ""
    @Published var password = ""
    @Published var newPassword = ""
    
    @Published var authenticationState: UserAuthState = .unauthenticated

    init(authenticationService: (Authenticating & EmailPasswordHandling), userManager: UserFirestoreService) {
        self.authenticationService = authenticationService
        self.userManager = userManager
        
        observeAuthState()
    }
    
    // Adicionando listener para o estado de autenticação:
    func observeAuthState() {
        authenticationService.onAuthStateChanged = { [weak self] state in
            guard let self = self else { return }
            self.authenticationState = state
        }
    }
    
    func signUpWithEmail() {
        guard !email.isEmpty, !password.isEmpty else {
            print("Not email or password found.")
            return
        }
        
        Task {
            do {
                let returnedData = try await authenticationService.createUser(email: email, password: password)
                print("Successfully signed up: \(returnedData)")
                
                // Usando o inicializador que aceita AuthDataResultModel
                let user = DBUser(auth: returnedData)
                
                // UserManager must create a User in FireStore
                try await userManager.createNewUser(user: user)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signInWithEmail() {
        guard !email.isEmpty, !password.isEmpty else {
            print("Not email or password found.")
            return
        }
        
        Task {
            do {
                let returnedData = try await authenticationService.signInUser(email: email, password: password)
                print("Successfully signed in: \(returnedData)")
            } catch {
                print(error.localizedDescription)
            }
        }
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
}
