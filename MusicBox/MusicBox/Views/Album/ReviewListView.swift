//
//  AlbumListView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//


import SwiftUI
import SwiftData
import FirebaseAuth

struct ReviewListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reviews: [AlbumReview] // Fetch all reviews from SwiftData
    
    @State private var starSize: CGFloat = 25
    @State private var starEditable: Bool = false
    @State private var sortOption: SortOption = .dateLogged // Default sorting by date
    @State private var currentUserId: String? = nil
    
    @ObservedObject var coordinator: AlbumListCoordinator
    
    enum SortOption: String, CaseIterable, Identifiable {
        case artist = "Artist"
        case album = "Album"
        case dateLogged = "Date Logged"
        
        var id: String { self.rawValue }
    }
    
    // Filter reviews to only show those by the current user
    var currentUserReviews: [AlbumReview] {
        guard let currentUserId = currentUserId else { return [] }
        return reviews.filter { $0.userId == currentUserId }
    }
    
    // Sort the filtered reviews
    var sortedReviews: [AlbumReview] {
        switch sortOption {
        case .artist:
            return currentUserReviews.sorted { $0.album.artist.localizedCompare($1.album.artist) == .orderedAscending }
        case .album:
            return currentUserReviews.sorted { $0.album.name.localizedCompare($1.album.name) == .orderedAscending }
        case .dateLogged:
            return currentUserReviews.sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("My Reviews")
                    .font(.system(size: 25, weight: .bold))
                    .padding(.vertical)
                    .padding(.leading)
                
                Picker("Sort by", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if sortedReviews.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding()
                        Text("No reviews yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Log albums to see them here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    List {
                        ForEach(sortedReviews) { review in
                            Button(action: {
                                coordinator.navigate(to: .reviewDetail(review))
                            }) {
                                ReviewComponentView(review: review)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteReview)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image(.musicboxLogo)
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("MusicBox")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(.systemRed)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                // Notification Bell or other toolbar items
            }
        }
        .onAppear {
            // Get current user ID from Firebase Auth
            if let userId = Auth.auth().currentUser?.uid {
                currentUserId = userId
            }
            
            // Update review dates if needed
            for review in currentUserReviews {
                if !review.isLogged {
                    review.date = Date()
                    review.isLogged = true
                }
            }
        }
    }
    
    private func deleteReview(at offsets: IndexSet) {
        for index in offsets {
            let reviewToDelete = sortedReviews[index]
            if let actualIndex = reviews.firstIndex(where: { $0.id == reviewToDelete.id }) {
                modelContext.delete(reviews[actualIndex])
            }
        }
        try? modelContext.save()
    }
}

// Remove the old ReviewRowView since we're using ReviewComponentView
