//
//  SongComponentView.swift
//  Statik
//
//  Created by Luca on 06/03/25.
//

import SwiftUI

struct SongComponentView: View {
    @ObservedObject var songReview: SongReviewDraft
    var smallStarSize: CGFloat
    var editable: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                
                Text("\(songReview.song.trackNumber). \(songReview.song.title)")
                    .font(.system(size: 20, weight: .semibold))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                
                HStack(spacing: 6) {
                    Text(songReview.song.album.artist)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    RatingView(
                        rating: $songReview.grade,
                        starSize: .constant(smallStarSize),
                        editable: editable
                    )
                }
                
                if !songReview.reviewText.isEmpty {
                    Text(songReview.reviewText)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if songReview.isLiked {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
}

