//
//  SocialReviewsSheetEnum.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//


//
//  SocialReviewsSheetEnum.swift
//  MusicBox
//

import Foundation

public enum SocialReviewsSheetEnum: Identifiable {
    case placeholder

    public var id: String {
        switch self {
        case .placeholder: return "placeholder"
        }
    }
}
