//
//  AlbumDetailViewModel.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//

import Foundation
import FirebaseAuth

@MainActor
class AlbumDetailViewModel: ObservableObject {
    @Published var username: String? = nil
    
    private let authenticationService: Authenticating
    private let userManager: UserFirestoreService
    
    init(authenticationService: Authenticating, userManager: UserFirestoreService) {
        self.authenticationService = authenticationService
        self.userManager = userManager
    }
    
    func loadUsername() async {
        do {
            let authResult = try authenticationService.getAuthenticatedUser()
            let user = try await userManager.getUser(userID: authResult.uid)
            // FIX: Make sure DBUser has a username property
            self.username = user.email
        } catch {
            print("❌ Failed to fetch username: \(error)")
            self.username = nil
        }
    }
}
