//
//  SongComponentView.swift
//  Statik
//
//  Created by Luca on 06/03/25.
//

import SwiftUI

struct SongComponentView: View {

    @Binding var song: Song
    @Binding var artist: String
    @Binding var smallStarSize: CGFloat
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                
                // Title (always once)
                Text(song.title)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                // Artist + Stars
                HStack(alignment: .center, spacing: 4) {
                    Text(artist)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    RatingView(
                        rating: Binding(
                            get: { song.grade },
                            set: { song.grade = $0 }
                        ),
                        starSize: $smallStarSize,
                        editable: .constant(false)
                    )
                    .allowsHitTesting(false)
                }
                
                // Review if present
                if !song.review.isEmpty {
                    Text(song.review)
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            if song.isLiked {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.systemRed)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary.opacity(0.5))
        }
    }
}


