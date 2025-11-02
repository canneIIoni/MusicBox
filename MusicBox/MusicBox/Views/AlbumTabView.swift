//
//  AlbumTabView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//

import SwiftUI

struct AlbumTabView: View {
    
    private var authenticationService: (Authenticating & EmailPasswordHandling)
    private let userManager: UserFirestoreService
    private let loginViewModel: LoginViewModel
    private let profileViewModel: MainProfileViewModel
    
    init() {
        // Inicializando Firebase Service
        self.authenticationService = FirebaseAuthService()
        self.userManager = UserFirestoreService()
        self.loginViewModel = LoginViewModel(authenticationService: authenticationService, userManager: userManager)
        self.profileViewModel = MainProfileViewModel(authenticationService: authenticationService, userManager: userManager)
    }
    
    var body: some View {
        TabView {
            AlbumListView()
                .tabItem {
                    Label("My Albums", systemImage: "music.note.list")
                }

            AlbumSearchView()
                .tabItem {
                    Label("Search Discogs", systemImage: "magnifyingglass")
                }
            
            
            LoginView(viewModel: loginViewModel)
                .tabItem {
                    Label("Login", systemImage: "person.crop.circle")
                }
            
        }
    }
}

#Preview {
    AlbumTabView()
}
