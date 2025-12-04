//
//  AlbumTabView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//

import SwiftUI

struct AlbumTabView: View {
    
    @StateObject private var albumListCoordinator: AlbumListCoordinator
    @StateObject private var albumSearchCoordinator: AlbumSearchCoordinator
    @StateObject private var socialReviewsCoordinator: SocialReviewsCoordinator
    
    @ObservedObject var authenticationService: FirebaseAuthService
    @StateObject private var profileViewModel: MainProfileViewModel
    
    // MARK: - Selected tab for UI Tests
    @State private var selectedTab: Int = 0
    
    // MARK: - Init with user info
    init(authenticationService: FirebaseAuthService, userId: String, username: String?) {
        self.authenticationService = authenticationService
        
        // Create UserFirestoreService instance for coordinators
        let userManager = UserFirestoreService()
        
        // Initialize all coordinators with user info
        self._albumListCoordinator = StateObject(
            wrappedValue: AlbumListCoordinator(
                authenticationService: authenticationService,
                userManager: userManager
            )
        )
        self._albumSearchCoordinator = StateObject(
            wrappedValue: AlbumSearchCoordinator(
                authenticationService: authenticationService,
                userManager: userManager
            )
        )
        self._socialReviewsCoordinator = StateObject(
            wrappedValue: SocialReviewsCoordinator(
                authenticationService: authenticationService,
                userManager: userManager
            )
        )
        
        // Use the same userManager for profileViewModel
        self._profileViewModel = StateObject(wrappedValue: MainProfileViewModel(
            authenticationService: authenticationService,
            userManager: userManager
        ))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            AlbumListCoordinatorView(coordinator: albumListCoordinator)
                .tabItem { Label("My Albums", systemImage: "music.note.list") }
                .tag(0)
            
            AlbumSearchCoordinatorView(coordinator: albumSearchCoordinator)
                .tabItem { Label("Search Discogs", systemImage: "magnifyingglass") }
                .tag(1)
            
            SocialReviewsCoordinatorView(coordinator: socialReviewsCoordinator)
                .tabItem { Label("Reviews", systemImage: "text.bubble.fill") }
                .tag(2)
            
            MainProfileView(viewModel: profileViewModel)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(3)
        }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("--ui-test-open-search-tab") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.selectedTab = 1 }
            }
        }
    }
}
