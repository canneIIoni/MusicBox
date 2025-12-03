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
            VStack(alignment: .leading, spacing: 4) {
                // Song title
                Text(song.title)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                // Artist name
                Text(artist)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 4)
    }
}


