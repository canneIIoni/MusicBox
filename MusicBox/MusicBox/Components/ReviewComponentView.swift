//
//  AlbumComponentView.swift
//  MusicBox
//
//  Created by Luca on 03/10/25.
//

import SwiftUI

struct ReviewComponentView: View {
    var review: AlbumReview
    var remoteImageURL: String? = nil
    
    @State var imageSize: CGFloat = 65
    @State private var isTitleTwoLines: Bool = false
    @State private var starSize: CGFloat = 17
    
    private let singleLineHeight: CGFloat = 24
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                
                // Album image (local or remote)
                if let localImage = review.album.albumImage {
                    Image(uiImage: localImage)
                        .resizable()
                        .frame(width: imageSize, height: imageSize)
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else if let remoteImageURL, let url = URL(string: remoteImageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: imageSize, height: imageSize)
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
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Title + HEART on same row
                    HStack(alignment: .firstTextBaseline) {
                        GeometryReader { geometry in
                            Text(review.album.name)
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
                        
                        Spacer()
                        
                        if review.isLiked {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 18))
                        }
                    }
                    
                    // Artist
                    Text(review.album.artist)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, -2)
                    
                    // Rating + Username (unchanged)
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center) {
                            RatingView(
                                rating: .constant(review.rating),
                                starSize: $starSize,
                                editable: false
                            )
                            
                            Spacer()
                            
                            Text(review.username ?? "Unknown")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            
            // Snippet of review text
            if !review.text.isEmpty {
                Text(review.text)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var fallbackImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: imageSize, height: imageSize)
            .overlay(Text("No Image").foregroundColor(.gray))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct TitleHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
