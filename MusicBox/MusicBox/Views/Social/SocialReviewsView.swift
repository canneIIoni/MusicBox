//
//  SocialReviewsView.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//


import SwiftUI
import SwiftData

struct SocialReviewsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reviews: [AlbumReview] // Automatically fetches from SwiftData
    @State private var starSize: CGFloat = 25
    @State private var starEditable: Bool = false
    @State private var sortOption: SortOption = .dateLogged // Default sorting by date
    
    @ObservedObject var coordinator: SocialReviewsCoordinator

    enum SortOption: String, CaseIterable, Identifiable {
        case artist = "Artist"
        case album = "Album"
        case dateLogged = "Most Recent"

        var id: String { self.rawValue }
    }

    var sortedAlbums: [AlbumReview] {
        switch sortOption {
        case .artist:
            return reviews.sorted { $0.album.artist.localizedCompare($1.album.artist) == .orderedAscending }
        case .album:
            return reviews.sorted { $0.album.name.localizedCompare($1.album.name) == .orderedAscending }
        case .dateLogged:
            return reviews.sorted { $0.date ?? Date() > $1.date ?? Date() }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]), // Adjust colors here
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(alignment: .leading) {
                Text("Social Feed")
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

                List {
                    ForEach(Array(sortedAlbums.enumerated()), id: \.element.id) { index, review in
                        Button {
                            coordinator.navigate(to: .reviewDetail(review))
                        } label: {
                            ReviewComponentView(review: review)
                        }
                        .accessibilityIdentifier(index == 0 ? "firstSocialReviewCell" : "SocialReviewCell_\(review.id)")
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
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
//                    Notification Bell
            }
        }
        .onAppear {
            for review in reviews {
                if !review.isLogged {
                    review.date = Date()
                }
            }
        }
    }
}
