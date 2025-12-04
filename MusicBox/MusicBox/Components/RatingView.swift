//
//  RatingView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//


import SwiftUI

struct RatingView: View {
    @Binding var rating: Double
    @Binding var starSize: CGFloat
    var editable: Bool  

    var body: some View {
        HStack(spacing: starSize * 0.2) {
            ForEach(0..<5, id: \.self) { index in
                starView(for: index)
                    .onTapGesture {
                        if editable {
                            updateRating(for: index)
                        }
                    }
            }
        }
    }

    private func starView(for index: Int) -> some View {
        let starValue = Double(index) + 1
        let fillType = starFillType(for: starValue)

        return Image(systemName: fillType.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: starSize, height: starSize)
            .foregroundColor(.systemRed)
    }

    private func starFillType(for starValue: Double) -> StarFillType {
        if rating >= starValue {
            return .full
        } else if rating >= starValue - 0.5 {
            return .half
        } else {
            return .empty
        }
    }

    private func updateRating(for index: Int) {
        let starValue = Double(index) + 1

        if starValue - 0.5 == rating {
            // If tapping the half-star, remove the rating
            rating = starValue - 1
        } else if starValue == rating {
            // If tapping a full star, switch it to half
            rating = starValue - 0.5
        } else {
            // Otherwise, set it to a full star
            rating = starValue
        }

        rating = max(0, min(rating, 5)) // Ensure within bounds
    }
}

enum StarFillType {
    case full, half, empty

    var imageName: String {
        switch self {
        case .full: return "star.fill"
        case .half: return "star.leadinghalf.filled"
        case .empty: return "star"
        }
    }
}

