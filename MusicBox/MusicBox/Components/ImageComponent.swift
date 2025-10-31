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

#Preview {
    struct Preview: View {
        @State var album = Album(name: "Meat is Murder", artist: "The Smiths", year: "1985", review: "berry gud", isLiked: true, grade: 4.5, dateLogged: Date())
        @State var imageSize: CGFloat = 100
        var body: some View {
            ImageComponent(album: $album, imageSize: $imageSize)
        }
    }

    return Preview()
}
