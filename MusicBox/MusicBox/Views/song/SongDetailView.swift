import SwiftUI

struct SongDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var songReview: SongReviewDraft

    @State private var localText: String = ""
    @State private var localRating: Double = 0
    @State private var localLiked: Bool = false
    @State private var showWarning = false

    @State private var starSize: CGFloat = 37
    @State private var starEditable: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // TITLE (Centered like the old version)
            Text(songReview.song.title)
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            // RATING + LIKE SECTION
            HStack {
                VStack(alignment: .leading) {
                    Text("Rating")
                        .font(.system(size: 16, weight: .bold))

                    RatingView( rating: $localRating, starSize: .constant(37), editable: true )
                }

                Spacer()

                VStack {
                    Text(localLiked ? "Liked" : "Like")
                        .font(.system(size: 16, weight: .bold))

                    Button {
                        localLiked.toggle()
                    } label: {
                        Image(systemName: localLiked ? "heart.circle.fill" : "heart.circle")
                            .font(.system(size: 37, weight: .bold))
                            .foregroundColor(.red)
                    }
                    .offset(y: 4)
                }
            }

            Divider()

            // REVIEW
            VStack(alignment: .leading) {
                Text("Review")
                    .font(.system(size: 16, weight: .bold))

                TextField("", text: $localText, prompt: Text("Write a review..."), axis: .vertical)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                    .lineLimit(6, reservesSpace: true)
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)

        // TOOLBAR
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    if hasUnsavedChanges {
                        showWarning = true
                    } else {
                        dismiss()
                    }
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.secondary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    applyChanges()
                    dismiss()
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.red)
            }
        }

        // ALERT
        .alert("Are you sure?", isPresented: $showWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Unsaved changes might be lost.")
        }

        // OLD STYLE BACKGROUND
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )

        // LOAD INITIAL VALUES
        .onAppear {
            localText = songReview.reviewText
            localRating = songReview.grade
            localLiked = songReview.isLiked
        }
    }

    // TRACK UNSAVED CHANGES
    private var hasUnsavedChanges: Bool {
        localText != songReview.reviewText ||
        localRating != songReview.grade ||
        localLiked != songReview.isLiked
    }

    // APPLY CHANGES
    private func applyChanges() {
        songReview.reviewText = localText
        songReview.grade = localRating
        songReview.isLiked = localLiked
    }
}
