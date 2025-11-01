//
//  ProfileView.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//


import SwiftUI

struct MainProfileView: View {
    
    @StateObject var viewModel: MainProfileViewModel
    
    var body: some View {
        VStack {
            List {
                Section("user info") {
                    Text(viewModel.user?.email ?? "No email found")
                    
                    
                    if let user = viewModel.user {
                        Text("UserID: \(user.userId)")
                        
                        if let isAnonymous = user.isAnonymous {
                            Text("isAnonymous: \(isAnonymous.description.capitalized)")
                        }
                        
                        if let isPremium = user.isPremium {
                        Button {
                            viewModel.togglePremiumStatus()
                        } label: {
                                Text("Premium status: \(isPremium.description.capitalized)")
                            }
                        }
                    }
                }
             
                
                Section("email") {
                    
                    Button {
                        // Sign Out
                        viewModel.signOut()
                    } label: {
                        Text("Log out")
                    }
                    
                    Button {
                        // Delete Account
                        //viewModel.signOut()
                    } label: {
                        Text("Delete account")
                    }
                    .foregroundStyle(.red)
                    
                    Button {
                        // Sign Out
                        viewModel.signOut()
                    } label: {
                        Text("Reset password")
                    }
                }
            }
            .task {
                try? await viewModel.loadCurrentUser()
            }
        }
    }
}

#Preview {
    MainProfileView(viewModel: MainProfileViewModel(authenticationService: FirebaseAuthService(), userManager: UserManager()))
}


class MainProfileViewModel: ObservableObject {
   // var coordinator: MainProfileTabCoordinator?
    
    let authenticationService: Authenticating
    let userManager: UserManager
    
    @Published private(set) var user: DBUser? = nil
    
    init(authenticationService: Authenticating, userManager: UserManager) {
        self.authenticationService = authenticationService
        self.userManager = userManager
    }
    
    func loadCurrentUser() async throws {
        let authResult  = try authenticationService.getAuthenticatedUser()
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
}
