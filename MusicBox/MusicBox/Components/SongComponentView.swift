//
//  SongComponentView.swift
//  Statik
//
//  Created by Luca on 06/03/25.
//

import SwiftUI

struct SongComponentView: View {
    @Binding var songReview: SongReview
    @Binding var smallStarSize: CGFloat
    var editable: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(songReview.trackNumber). \(songReview.title)")
                    .font(.system(size: 20))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Text(songReview.artist)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    RatingView(
                        rating: $songReview.grade,
                        starSize: $smallStarSize,
                        editable: .constant(editable)
                    )
                }

                if !songReview.reviewText.isEmpty {
                    Text(songReview.reviewText)
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()

            if songReview.isLiked {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.systemRed)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary.opacity(0.5))
        }
    }
}



