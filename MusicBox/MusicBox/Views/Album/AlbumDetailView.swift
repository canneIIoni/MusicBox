//
//  AlbumDetailView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//


import SwiftUI
import SwiftData

struct AlbumDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var album: Album
    @State private var starSize: CGFloat = 25
    @State private var imageSize: CGFloat = 147
    
    // Firebase user info
    var userId: String
    var username: String?
    
    var coordinator: AlbumListCoordinator?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
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
                
                // Songs
                VStack(alignment: .leading) {
                    ForEach(album.songs.sorted { $0.trackNumber < $1.trackNumber }) { song in
                        SearchedSongComponentView(
                            song: .constant(song),
                            artist: .constant($album.wrappedValue.artist),
                            smallStarSize: .constant(17)
                        )
                        .padding(.vertical, 8)
                    }
                }
                
                Spacer()
            }
            .padding(.leading, 15)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: logAlbumReview) {
                    Text("Log")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.systemRed)
                }
                .accessibilityIdentifier("albumDetailLogButton")
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
    }
    
    // MARK: - Log Album as Review
    private func logAlbumReview() {
        let review = AlbumReview(
            userId: userId,
            username: username,
            text: "",               // empty initially, user can edit later
            rating: 0.0,            // default
            date: Date(),
            album: album,
            isLiked: false
        )
        
        modelContext.insert(review)
        try? modelContext.save()
        
        // Optional: navigate to review view to edit immediately
        coordinator?.navigate(to: .reviewDetail(review))
    }
}

