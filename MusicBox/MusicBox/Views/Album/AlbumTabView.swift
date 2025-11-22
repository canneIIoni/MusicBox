//
//  AlbumTabView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//

import SwiftUI

struct AlbumTabView: View {
    
    @StateObject private var albumListCoordinator = AlbumListCoordinator()
    @StateObject private var albumSearchCoordinator = AlbumSearchCoordinator()
    
    @ObservedObject var authenticationService: FirebaseAuthService
    private let userManager = UserFirestoreService()
    @StateObject private var profileViewModel: MainProfileViewModel
    
    init(authenticationService: FirebaseAuthService) {
        self.authenticationService = authenticationService
        let userManager = UserFirestoreService()
        self._profileViewModel = StateObject(wrappedValue: MainProfileViewModel(
            authenticationService: authenticationService,
            userManager: userManager
        ))
    }
    
    var body: some View {
        TabView {
            AlbumListCoordinatorView(coordinator: albumListCoordinator)
                .tabItem {
                    Label("My Albums", systemImage: "music.note.list")
                }

            AlbumSearchCoordinatorView(coordinator: albumSearchCoordinator)
                .tabItem {
                    Label("Search Discogs", systemImage: "magnifyingglass")
                }
            
            MainProfileView(viewModel: profileViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    AlbumTabView(authenticationService: FirebaseAuthService())
}
