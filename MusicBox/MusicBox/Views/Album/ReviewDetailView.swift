//
//  ReviewDetailView.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct ReviewDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var review: AlbumReview
    @State private var starSize: CGFloat = 25
    @State private var imageSize: CGFloat = 147
    @State private var showSaveAlert = false
    @State private var currentUserId: String? = nil
    
    // Check if current user is the review owner
    private var isCurrentUserOwner: Bool {
        guard let currentUserId = currentUserId else { return false }
        return review.userId == currentUserId
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Album Header
                    AlbumHeaderView(album: review.album, imageSize: $imageSize)
                    
                    // Review Info
                    ReviewInfoView(
                        review: $review,
                        starSize: $starSize,
                        isCurrentUserOwner: isCurrentUserOwner
                    )
                    
                    // Review Text
                    ReviewTextView(
                        review: $review,
                        isCurrentUserOwner: isCurrentUserOwner
                    )
                    
                    // Song Reviews
                    SongReviewsView(
                        review: review,
                        isCurrentUserOwner: isCurrentUserOwner
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 15)
            }
        }
        .navigationTitle("")
        .toolbar {
            
            // Only show save button if user owns the review
            if isCurrentUserOwner {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        do {
                            try modelContext.save()
                            showSaveAlert = true
                        } catch {
                            print("❌ Failed to save review: \(error)")
                        }
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.systemRed)
                    .accessibilityIdentifier("reviewSaveButton")
                }
            }
        }
        
        .alert("Review Saved", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            // Get current user ID
            currentUserId = Auth.auth().currentUser?.uid
        }
    }
}

struct AlbumHeaderView: View {
    let album: Album
    @Binding var imageSize: CGFloat
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ImageComponent(album: .constant(album), imageSize: $imageSize)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Album · \(album.year ?? "Unknown Year")")
                    .font(.caption)
                    .foregroundStyle(.secondaryText)
                
                Text(album.name)
                    .font(.system(size: 25, weight: .bold))
                    .layoutPriority(1)
                
                Text(album.artist)
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
            }
        }
        .padding(.top, 20)
    }
}

struct ReviewInfoView: View {
    @Binding var review: AlbumReview
    @Binding var starSize: CGFloat
    let isCurrentUserOwner: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Rating - only editable if owner
            HStack {
                RatingView(
                    rating: $review.rating,
                    starSize: $starSize,
                    editable: .constant(isCurrentUserOwner)
                )
                .padding(.trailing, 8)
                
                Spacer()
                
                if review.isLiked {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.systemRed)
                        .font(.system(size: 22))
                }
            }
            
            // Username and date
            HStack {
                if let username = review.username {
                    Text(username)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                
                Text("•")
                    .foregroundStyle(.gray)
                
                Text(review.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                // Show owner badge
                if isCurrentUserOwner {
                    Text("(Your Review)")
                        .font(.caption)
                        .foregroundStyle(.systemRed)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.systemRed.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
    }
}

struct ReviewTextView: View {
    @Binding var review: AlbumReview
    let isCurrentUserOwner: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Review")
                .font(.headline)
                .foregroundStyle(.primary)
            
            if isCurrentUserOwner {
                TextEditor(text: $review.text)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .font(.body)
                    .accessibilityIdentifier("reviewTextEditor")
                
                Button(action: {
                    if isCurrentUserOwner {
                        review.isLiked.toggle()
                    }
                }) {
                    Image(systemName: review.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(review.isLiked ? .systemRed : .gray)
                        .font(.system(size: 22))
                }
                .accessibilityIdentifier("reviewLikeButton") 
                .disabled(!isCurrentUserOwner)
            } else {
                // Read-only version for non-owners
                Text(review.text.isEmpty ? "No review text yet" : review.text)
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .font(.body)
                    .foregroundStyle(review.text.isEmpty ? .gray : .primary)
            }
        }
    }
}

struct SongReviewsView: View {
    let review: AlbumReview
    let isCurrentUserOwner: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Songs")
                .font(.headline)
                .foregroundStyle(.primary)
            
            ForEach(review.songReviews.sorted { $0.trackNumber < $1.trackNumber }) { songReview in
                SongComponentView(
                    songReview: .constant(songReview),
                    smallStarSize: .constant(17),
                    editable: isCurrentUserOwner
                )
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}
