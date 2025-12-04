//
//  AlbumDetailViewModel.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//

import Foundation
import SwiftData
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

            if let email = user.email,
               let usernamePart = email.split(separator: "@").first {
                self.username = String(usernamePart)
            } else {
                self.username = nil
            }

        } catch {
            print("❌ Failed to fetch username: \(error)")
            self.username = nil
        }
    }
    
    // MARK: - Average Album Rating
    func averageRating(for album: Album, context: ModelContext) -> Double {
        // Capture actual values (SwiftData requires this)
        let albumName = album.name
        let albumArtist = album.artist

        let fetch = FetchDescriptor<AlbumReview>(
            predicate: #Predicate { review in
                review.album.name == albumName &&
                review.album.artist == albumArtist
            }
        )

        do {
            let reviews = try context.fetch(fetch)
            guard !reviews.isEmpty else { return 0 }

            let total = reviews.reduce(0) { $0 + $1.rating }
            return total / Double(reviews.count)

        } catch {
            print("⚠️ Error fetching album reviews: \(error)")
            return 0
        }
    }

}
