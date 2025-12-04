//
//  AlbumComponentView.swift
//  MusicBox
//
//  Created by Luca on 03/10/25.
//

import SwiftUI

struct AlbumComponentView: View {
    @Binding var album: Album
    var remoteImageURL: String? = nil
    
    @State var imageSize: CGFloat = 65
    @State private var isTitleTwoLines: Bool = false
    @State private var starSize: CGFloat = 17
    
    private let singleLineHeight: CGFloat = 24
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                
                // Try loading local image first, fallback to remote
                if let localImage = album.albumImage {
                    Image(uiImage: localImage)
                        .resizable()
                        .frame(width: imageSize, height: imageSize)
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else if let remoteImageURL, let url = URL(string: remoteImageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: imageSize, height: imageSize)
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: imageSize, height: imageSize)
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        case .failure:
                            fallbackImage
                        @unknown default:
                            fallbackImage
                        }
                    }
                } else {
                    fallbackImage
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Album title
                    GeometryReader { geometry in
                        Text(album.name)
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .background(
                                GeometryReader { titleGeometry in
                                    Color.clear.preference(
                                        key: TitleHeightKey.self,
                                        value: titleGeometry.size.height
                                    )
                                }
                            )
                    }
                    .frame(height: isTitleTwoLines ? 48 : singleLineHeight)
                    .onPreferenceChange(TitleHeightKey.self) { newHeight in
                        isTitleTwoLines = newHeight > singleLineHeight
                    }
                    
                    // Artist info (similar to ReviewComponentView but without extra elements)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(album.artist)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Optional: Add album year if available
                        if let year = album.year, !year.isEmpty {
                            Text("• \(year)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Optional: Add album description or other info if needed
            // Similar to the review text section in ReviewComponentView
            // if let description = album.description, !description.isEmpty {
            //     Text(description)
            //         .font(.system(size: 12))
            //         .foregroundColor(.gray)
            //         .lineLimit(2)
            // }
        }
        .padding(.vertical, 8)
    }
    
    private var fallbackImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: imageSize, height: imageSize)
            .overlay(
                Text("No Image")
                    .font(.caption)
                    .foregroundColor(.gray)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

