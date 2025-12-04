//
//  AlbumReviewView.swift
//  MusicBox
//
//  Created by Luca on 22/11/25.
//


import SwiftUI
import SwiftData

struct AlbumReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var review: AlbumReview
    
    @State private var starSize: CGFloat = 37
    @State private var starEditable: Bool = true
    @State private var reviewText: String = ""
    @State private var rating: Double = 0
    @State private var showWarning = false
    @State private var imageSize: CGFloat = 65
    
    var body: some View {
        VStack {
            HStack {
                // Album image
                ImageComponent(album: .constant(review.album), imageSize: $imageSize)
                
                VStack(alignment: .leading) {
                    Text("Album · \(review.album.year ?? "Unknown Year")")
                        .font(.caption)
                        .foregroundStyle(.secondaryText)
                    Text(review.album.name)
                        .font(.title2)
                        .bold()
                    Text(review.album.artist)
                        .font(.system(size: 16))
                    Spacer()
                }.frame(height: 65)
                
                Spacer()
            }
            .padding(.bottom)
            
            Divider().padding(.bottom)

            HStack {
                VStack(alignment: .leading) {
                    Text("Rating")
                        .font(.system(size: 16, weight: .bold))
                    RatingView(rating: $review.rating, starSize: $starSize, editable: starEditable)
                        .accessibilityIdentifier("albumReviewRatingView")
                }.padding(.bottom)
                
                Spacer()
                
                VStack(alignment: .center) {
                    if review.isLiked {
                        Text("Liked").font(.system(size: 16, weight: .bold))
                    } else {
                        Text("Like").font(.system(size: 16, weight: .bold))
                    }
                    Button(action: toggleLike) {
                        Image(systemName: review.isLiked ? "heart.circle.fill" : "heart.circle")
                            .foregroundColor(.systemRed)
                            .font(.system(size: 37, weight: .bold))
                    }
                    .offset(y: 4)
                    .accessibilityIdentifier("albumReviewLikeButton")
                }.padding(.bottom)
            }
            
            Divider().padding(.bottom)
            
            HStack {
                Text("Review")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }

            TextField("", text: $reviewText, prompt: Text("Write a review..."), axis: .vertical)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColorDark))
                .lineLimit(6, reservesSpace: true)
                .accessibilityIdentifier("albumReviewTextField")
                
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if review.text != reviewText || review.rating != rating {
                        showWarning = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.secondaryText)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    review.text = reviewText
                    review.rating = rating
                    review.date = Date()
                    try? modelContext.save()
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.systemRed)
                }
                .accessibilityIdentifier("albumReviewSaveButton")
            }
        }
        .alert("Are you sure?", isPresented: $showWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm", role: .destructive) {
                reviewText = review.text
                rating = review.rating
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("Unsaved changes might be lost.")
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
        .onDisappear {
            review.text = reviewText
            review.rating = rating
            try? modelContext.save()
        }
        .onAppear {
            reviewText = review.text
            rating = review.rating
        }
    }

    private func toggleLike() {
        review.isLiked.toggle()
    }
}

