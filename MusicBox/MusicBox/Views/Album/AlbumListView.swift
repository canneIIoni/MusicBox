//
//  AlbumListView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//


import SwiftUI
import SwiftData

struct ReviewListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reviews: [AlbumReview] // Fetch reviews from SwiftData

    @State private var starSize: CGFloat = 25
    @State private var sortOption: SortOption = .date // Default sorting by date

    @ObservedObject var coordinator: AlbumListCoordinator

    enum SortOption: String, CaseIterable, Identifiable {
        case album = "Album"
        case artist = "Artist"
        case date = "Date"

        var id: String { self.rawValue }
    }

    var sortedReviews: [AlbumReview] {
        switch sortOption {
        case .album:
            return reviews.sorted { $0.album.name.localizedCompare($1.album.name) == .orderedAscending }
        case .artist:
            return reviews.sorted { $0.album.artist.localizedCompare($1.album.artist) == .orderedAscending }
        case .date:
            return reviews.sorted { $0.date > $1.date }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Logged Reviews")
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
                ForEach(sortedReviews) { review in
                    Button {
                        coordinator.navigate(to: .reviewDetail(review))
                    } label: {
                        ReviewRowView(review: review)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .onDelete(perform: deleteReview)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private func deleteReview(at offsets: IndexSet) {
        for index in offsets {
            let reviewToDelete = sortedReviews[index]
            modelContext.delete(reviewToDelete)
        }
        try? modelContext.save()
    }
}

struct ReviewRowView: View {
    var review: AlbumReview
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(review.album.name) · \(review.album.artist)").bold()
            RatingView(rating: .constant(review.rating), starSize: .constant(20), editable: .constant(false))
            Text(review.text).lineLimit(2)
        }.padding(.vertical, 4)
    }
}

