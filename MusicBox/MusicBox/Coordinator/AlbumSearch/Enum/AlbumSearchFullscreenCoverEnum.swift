//
//  AlbumSearchFullscreenCoverEnum.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

public enum AlbumSearchFullscreenCoverEnum: Identifiable {
    case placeholder
    
    public var id: String {
        switch self {
        case .placeholder:
            return "placeholder"
        }
    }
}

