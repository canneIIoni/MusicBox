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
    @Query private var reviews: [AlbumReview]

    @State private var currentUserId: String?
    @State private var sortOption: SortOption = .dateLogged

    @ObservedObject var coordinator: AlbumListCoordinator

    enum SortOption: String, CaseIterable, Identifiable {
        case artist = "Artist"
        case album = "Album"
        case dateLogged = "Date Logged"
        var id: String { rawValue }
    }

    var currentUserReviews: [AlbumReview] {
        guard let currentUserId else { return [] }
        return reviews.filter { $0.userId == currentUserId }
    }

    var sortedReviews: [AlbumReview] {
        switch sortOption {
        case .artist:
            return currentUserReviews.sorted {
                $0.album.artist.localizedCompare($1.album.artist) == .orderedAscending
            }
        case .album:
            return currentUserReviews.sorted {
                $0.album.name.localizedCompare($1.album.name) == .orderedAscending
            }
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
                            Button {
                                coordinator.navigate(to: .reviewDetail(review))
                            } label: {
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
        .navigationBarBackButtonHidden(true)  // <-- hides back button globally
        .toolbar {
            // REQUIRED: removes system back button fully
            ToolbarItem(placement: .cancellationAction) {
                EmptyView()
            }

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
        }
        .onAppear {
            if let uid = Auth.auth().currentUser?.uid {
                currentUserId = uid
            }
            
            // Set dateLogged if needed
            for review in currentUserReviews where !review.isLogged {
                review.date = Date()
                review.isLogged = true
            }
        }
    }

    private func deleteReview(at offsets: IndexSet) {
        for index in offsets {
            let reviewToDelete = sortedReviews[index]
            if let realIndex = reviews.firstIndex(where: { $0.id == reviewToDelete.id }) {
                modelContext.delete(reviews[realIndex])
            }
        }
        try? modelContext.save()
    }
}
