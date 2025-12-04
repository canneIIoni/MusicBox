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
    @Environment(\.dismiss) private var dismiss

    @State var review: AlbumReview
    @StateObject private var draft: AlbumReviewDraft

    @State private var starSize: CGFloat = 25
    @State private var imageSize: CGFloat = 147
    @State private var showSaveAlert = false
    @State private var showBackWarning = false

    @State private var currentUserId: String? = nil

    init(review: AlbumReview) {
        _review = State(initialValue: review)
        _draft = StateObject(wrappedValue: review.makeDraft())
    }

    private var isCurrentUserOwner: Bool {
        guard let currentUserId else { return false }
        return review.userId == currentUserId
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AlbumHeaderView(album: review.album, imageSize: $imageSize)

                ReviewInfoView(
                    draft: draft,
                    starSize: $starSize,
                    isCurrentUserOwner: isCurrentUserOwner
                )

                ReviewTextView(
                    draft: draft,
                    isCurrentUserOwner: isCurrentUserOwner
                )

                SongReviewsView(
                    draft: draft,
                    isCurrentUserOwner: isCurrentUserOwner
                )
            }
            .padding(.horizontal)
        }
        .toolbar {
            // Custom back button (with unsaved changes warning)
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if review.isDifferent(from: draft) {
                        showBackWarning = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
            }

            // Save button (only if owner)
            if isCurrentUserOwner {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        review.applyDraft(draft)
                        try? modelContext.save()
                        showSaveAlert = true
                    }
                    .foregroundStyle(.systemRed)
                }
            }
        }

        // ✅ Added GRADIENT BACKGROUND (same as AlbumDetailView)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )

        .alert("Review Saved", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        }
        .alert("Unsaved changes", isPresented: $showBackWarning) {
            Button("Stay", role: .cancel) {}
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You have unsaved changes. Leaving will discard them.")
        }
        .onAppear {
            currentUserId = Auth.auth().currentUser?.uid
        }
        .navigationBarBackButtonHidden(true)
    }
}



// MARK: - Album Header

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


// MARK: - Review Info (Stars under album header)

struct ReviewInfoView: View {
    @ObservedObject var draft: AlbumReviewDraft
    @Binding var starSize: CGFloat
    let isCurrentUserOwner: Bool

    var body: some View {
        HStack {
            RatingView(
                rating: $draft.rating,
                starSize: $starSize,
                editable: false
            )
            Spacer()
            if draft.isLiked {
                Image(systemName: "heart.fill")
                    .foregroundColor(.systemRed)
            }
        }
    }
}


// MARK: - Review Text

struct ReviewTextView: View {
    @ObservedObject var draft: AlbumReviewDraft
    let isCurrentUserOwner: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Review").font(.headline)

            if isCurrentUserOwner {
                TextEditor(text: $draft.text)
                    .scrollContentBackground(.hidden) // <-- removes the black background
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))  // <-- your gray background
                    .cornerRadius(8)
                    .padding(.bottom, 5)

                HStack {
                    Button { draft.isLiked.toggle() } label: {
                        Image(systemName: draft.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(draft.isLiked ? .systemRed : .gray)
                    }

                    InlineEditableRatingView(
                        rating: $draft.rating,
                        isCurrentUserOwner: true
                    )
                }
            } else {
                Text(draft.text.isEmpty ? "No review yet" : draft.text)
            }
        }
    }
}


// MARK: - Song Reviews

struct SongReviewsView: View {
    @ObservedObject var draft: AlbumReviewDraft
    let isCurrentUserOwner: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Songs").font(.headline)

            ForEach(draft.songReviews) { songReview in
                NavigationLink {
                    SongDetailView(songReview: songReview)
                } label: {
                    SongComponentView(
                        songReview: songReview,
                        smallStarSize: 17,
                        editable: isCurrentUserOwner
                    )
                }
            }
        }
    }
}


// MARK: - Inline Editable Stars

struct InlineEditableRatingView: View {
    @Binding var rating: Double
    let isCurrentUserOwner: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { starIndex in
                Image(systemName: starFillType(for: starIndex).imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.systemRed)
                    .onTapGesture {
                        guard isCurrentUserOwner else { return }
                        rating = newRating(for: starIndex)
                    }
            }
        }
    }
    
    private func starFillType(for starValue: Int) -> StarFillType {
        if rating >= Double(starValue) {
            return .full
        } else if rating >= Double(starValue) - 0.5 {
            return .half
        } else {
            return .empty
        }
    }
    
    private func newRating(for starValue: Int) -> Double {
        let starDouble = Double(starValue)

        if rating == starDouble {
            return starDouble - 0.5
        } else if rating == starDouble - 0.5 {
            return starDouble - 1
        } else {
            return starDouble
        }
    }
}


// MARK: - Draft Models

final class SongReviewDraft: ObservableObject, Identifiable {
    let id = UUID()

    @Published var grade: Double
    @Published var reviewText: String
    @Published var isLiked: Bool
    @Published var song: Song

    init(grade: Double, reviewText: String, isLiked: Bool, song: Song) {
        self.grade = grade
        self.reviewText = reviewText
        self.isLiked = isLiked
        self.song = song
    }
}

final class AlbumReviewDraft: ObservableObject {
    @Published var text: String
    @Published var rating: Double
    @Published var isLiked: Bool
    @Published var songReviews: [SongReviewDraft]

    init(text: String, rating: Double, isLiked: Bool, songReviews: [SongReviewDraft]) {
        self.text = text
        self.rating = rating
        self.isLiked = isLiked
        self.songReviews = songReviews
    }
}


// MARK: - AlbumReview Extensions

extension AlbumReview {

    func makeDraft() -> AlbumReviewDraft {
        AlbumReviewDraft(
            text: self.text,
            rating: self.rating,
            isLiked: self.isLiked,
            songReviews: self.songReviews.map { sr in
                SongReviewDraft(
                    grade: sr.grade,
                    reviewText: sr.reviewText,
                    isLiked: sr.isLiked,
                    song: sr.song
                )
            }
        )
    }

    func applyDraft(_ draft: AlbumReviewDraft) {
        self.text = draft.text
        self.rating = draft.rating
        self.isLiked = draft.isLiked

        for draftSR in draft.songReviews {
            if let target = self.songReviews.first(where: { $0.song.id == draftSR.song.id }) {
                target.grade = draftSR.grade
                target.reviewText = draftSR.reviewText
                target.isLiked = draftSR.isLiked
            }
        }
    }

    /// 🔍 Detect if draft is different from the original review
    func isDifferent(from draft: AlbumReviewDraft) -> Bool {
        if self.text != draft.text { return true }
        if self.rating != draft.rating { return true }
        if self.isLiked != draft.isLiked { return true }

        for sr in draft.songReviews {
            guard let original = self.songReviews.first(where: { $0.song.id == sr.song.id }) else { continue }

            if original.grade != sr.grade { return true }
            if original.reviewText != sr.reviewText { return true }
            if original.isLiked != sr.isLiked { return true }
        }

        return false
    }
}
