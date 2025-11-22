//
//  AlbumListSheetEnum.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

public enum AlbumListSheetEnum: Identifiable {
    case addAlbum
    
    public var id: String {
        switch self {
        case .addAlbum:
            return "addAlbum"
        }
    }
}

