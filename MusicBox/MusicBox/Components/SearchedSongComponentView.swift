//
//  SearchedSongComponentView.swift
//  Statik
//
//  Created by Luca on 01/05/25.
//


import SwiftUI

struct SearchedSongComponentView: View {
    
    @Binding var song: Song
    @Binding var artist: String
    @Binding var smallStarSize: CGFloat
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
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
                        .opacity(0)
                    // VERY MUCH THE WRONG THING TO DO, THIS IS SOME NASTY IMPROV
                }
                Text("\(artist)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
    }
}


