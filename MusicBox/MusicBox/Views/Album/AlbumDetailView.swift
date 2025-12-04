//
//  AlbumDetailView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct AlbumDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var album: Album
    @State private var starSize: CGFloat = 25
    @State private var imageSize: CGFloat = 147
    
    @StateObject private var viewModel: AlbumDetailViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var hasExistingReview = false
    @State private var existingReview: AlbumReview?
    
    // For NavigationLink
    @State private var createdReview: AlbumReview?
    @State private var navigateToReview = false
    
    var coordinator: AlbumListCoordinator?
    
    // MARK: - Init
    init(
        album: Album,
        viewModel: AlbumDetailViewModel,
        coordinator: AlbumListCoordinator? = nil
    ) {
        self._album = State(initialValue: album)
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Album Info
                AlbumInfoHeaderView(album: $album, imageSize: $imageSize)
                
                // Songs
                SongsListView(album: album)
                
                Spacer()
            }
            .padding(.leading, 15)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                LogButtonView(hasExistingReview: hasExistingReview) {
                    if hasExistingReview, let existingReview = existingReview {
                        navigateToExistingReview(existingReview)
                    } else {
                        Task {
                            await logAlbumReview()
                        }
                    }
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
        // Hidden NavigationLink for fallback navigation
        .background(
            NavigationLink(
                destination: Group {
                    if let review = createdReview {
                        ReviewDetailView(review: review)
                    }
                },
                isActive: $navigateToReview,
                label: { EmptyView() }
            )
            .hidden()
        )
        .task {
            await viewModel.loadUsername()
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkExistingReview()
        }
    }
    
    private func checkExistingReview() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Get all reviews by this user
        let fetchDescriptor = FetchDescriptor<AlbumReview>(
            predicate: #Predicate<AlbumReview> { review in
                review.userId == userId
            }
        )
        
        do {
            let userReviews = try modelContext.fetch(fetchDescriptor)
            
            // Filter for albums with same name, artist, and year
            let existingReviews = userReviews.filter { review in
                let sameName = review.album.name.lowercased() == album.name.lowercased()
                let sameArtist = review.album.artist.lowercased() == album.artist.lowercased()
                let sameYear = review.album.year == album.year
                
                return sameName && sameArtist && sameYear
            }
            
            if let firstReview = existingReviews.first {
                hasExistingReview = true
                existingReview = firstReview
                print("✅ Found existing review for this album (same name, artist, year)")
            } else {
                hasExistingReview = false
                existingReview = nil
                print("❌ No existing review found for this album")
            }
        } catch {
            print("⚠️ Error checking existing reviews: \(error)")
        }
    }

    private func navigateToExistingReview(_ review: AlbumReview) {
        if let coordinator = coordinator {
            coordinator.navigate(to: .reviewDetail(review))
        } else {
            self.createdReview = review
            self.navigateToReview = true
        }
    }
    
    private func logAlbumReview() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "No user logged in"
            showAlert = true
            return
        }
        
        // Double-check (in case of race condition)
        if hasExistingReview {
            alertMessage = "You already have a review for this album"
            showAlert = true
            return
        }
    
        print("🔍 [logAlbumReview] User ID: \(userId)")
        
        // Ensure username is loaded
        if viewModel.username == nil {
            print("🔍 [logAlbumReview] Loading username...")
            await viewModel.loadUsername()
        }
        
        print("🔍 [logAlbumReview] Username: \(viewModel.username ?? "nil")")
        
        // Create the review with the username
        let review = AlbumReview(
            userId: userId,
            username: viewModel.username,
            text: "",
            rating: 0.0,
            date: Date(),
            album: album,
            isLiked: false
        )
        
        // Set isLogged to true since we're logging it now
        review.isLogged = true
        
        print("🔍 [logAlbumReview] Created AlbumReview with \(album.songs.count) songs")
        
        // CREATE SONG REVIEWS FOR EACH SONG IN THE ALBUM
        for song in album.songs.sorted(by: { $0.trackNumber < $1.trackNumber }) {
            print("🔍 [logAlbumReview] Creating SongReview for: \(song.title)")
            let songReview = SongReview(
                song: song,
                grade: 0.0,
                reviewText: ""
            )
            review.songReviews.append(songReview)
        }
        
        print("🔍 [logAlbumReview] Created \(review.songReviews.count) song reviews")
        
        modelContext.insert(review)
        
        do {
            try modelContext.save()
            print("✅ [logAlbumReview] Review saved successfully!")
            
            // Try coordinator navigation first, then fallback to NavigationLink
            await MainActor.run {
                if let coordinator = coordinator {
                    print("🔍 [logAlbumReview] Using coordinator navigation...")
                    coordinator.navigate(to: .reviewDetail(review))
                } else {
                    print("🔍 [logAlbumReview] Coordinator is nil, using NavigationLink fallback...")
                    self.createdReview = review
                    self.navigateToReview = true
                }
            }
        } catch {
            print("❌ [logAlbumReview] Failed to save review: \(error)")
            alertMessage = "Failed to save review: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

struct AlbumInfoHeaderView: View {
    @Binding var album: Album
    @Binding var imageSize: CGFloat
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ImageComponent(album: $album, imageSize: $imageSize)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Album · \(album.year ?? "Unknown Year")")
                    .font(.caption)
                    .foregroundStyle(.secondaryText)
                
                Text(album.name)
                    .font(.system(size: 25, weight: .bold))
                    .layoutPriority(1)
                    .accessibilityIdentifier("albumDetailTitle")
                
                Text(album.artist)
                    .font(.system(size: 16))
            }
        }
        .padding(.top, 20)
    }
}

struct SongsListView: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(album.songs.sorted { $0.trackNumber < $1.trackNumber }) { song in
                SearchedSongComponentView(
                    song: .constant(song),
                    artist: .constant(album.artist),
                    smallStarSize: .constant(17)
                )
                .padding(.vertical, 8)
            }
        }
    }
}

struct LogButtonView: View {
    let hasExistingReview: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if hasExistingReview {
                Text("View Review")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.gray)
            } else {
                Text("Log")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.systemRed)
            }
        }
        .accessibilityIdentifier("albumDetailLogButton")
    }
}
