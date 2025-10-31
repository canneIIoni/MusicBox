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
            VStack(alignment: .leading) {
                if song.title.count < 20 {
                    HStack(alignment: .bottom) {
                        Text("\(song.title) ")
                            .font(.system(size: 20))
                            .multilineTextAlignment(.leading)
                        RatingView(
                            rating: Binding(
                                get: { song.grade },
                                set: { song.grade = $0 }
                            ),
                            starSize: $smallStarSize,
                            editable: .constant(false)
                        ).allowsHitTesting(false)
                            .padding(.bottom, 3.2)
                    }
                    Text("\(artist)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    
                } else {
                    if song.title.count < 36 {
                        Text("\(song.title) ")
                            .font(.system(size: 20))
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text("\(artist)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Text("\(song.title) ")
                            .font(.system(size: 20))
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 1)
                        
                        HStack {
                            Text("\(artist)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                            
                            RatingView(
                                rating: Binding(
                                    get: { song.grade },
                                    set: { song.grade = $0 }
                                ),
                                starSize: $smallStarSize,
                                editable: .constant(false)
                            ).allowsHitTesting(false)
                                .padding(.bottom, 3.2)
                        }
                        
                    }
                    
                    if song.title.count >= 20 && song.title.count < 36 {
                        
                        if !song.review.isEmpty {
                            Text("\(song.review)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.leading)
                        }
                    } else {
                        
                        if !song.review.isEmpty {
                            Text("\(song.review)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.leading)
                            
                        }
                    }
                }
            }
            Spacer()
            if song.isLiked {
                Image(systemName: "heart.circle.fill")
                    .foregroundColor(.systemRed)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary).opacity(0.5)
        }
    }
}

