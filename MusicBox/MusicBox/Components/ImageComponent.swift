//
//  ImageComponent.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//


import SwiftUI

struct ImageComponent: View {
    
    @Binding var album: Album
    @Binding var imageSize: CGFloat
    
    var body: some View {
        if let image = album.albumImage {
            Image(uiImage: image)
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: imageSize, height: imageSize)
                .overlay(Text("No Image").foregroundColor(.gray))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
