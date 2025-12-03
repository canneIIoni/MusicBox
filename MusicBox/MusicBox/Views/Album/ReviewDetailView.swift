//
//  ReviewDetailView.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//

import SwiftUI
import SwiftData

struct ReviewDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var review: AlbumReview
    @State private var starSize: CGFloat = 25
    @State private var starEditable: Bool = true
    @State private var imageSize: CGFloat = 147
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                HStack(alignment: .top, spacing: 16) {
                    ImageComponent(album: .constant(review.album), imageSize: $imageSize)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Album · \(review.album.year ?? "Unknown Year")")
                            .font(.caption)
                            .foregroundStyle(.secondaryText)
                        
                        Text(review.album.name)
                            .font(.system(size: 25, weight: .bold))
                            .layoutPriority(1)
                        
                        Text(review.album.artist)
                            .font(.system(size: 16))
                    }
                }
                
                HStack {
                    RatingView(rating: $review.rating, starSize: $starSize, editable: $starEditable)
                    
                    if review.isLiked {
                        Image(systemName: "heart.circle.fill")
                            .resizable()
                            .foregroundColor(.systemRed)
                            .frame(width: starSize, height: starSize)
                    }
                }
                
                Text(review.text)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondaryText)
                
                VStack(alignment: .leading) {
                    ForEach(review.songReviews.sorted { $0.trackNumber < $1.trackNumber }) { songReview in
                        SongComponentView(
                            songReview: .constant(songReview),
                            artist: .constant(review.album.artist),
                            smallStarSize: .constant(17)
                        )
                        .padding(.vertical, 8)
                    }
                }

            }
            .padding(.horizontal, 15)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    try? modelContext.save()
                }
            }
        }
    }
}

