//
//  AlbumListDestinationEnum.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

import Foundation

public enum AlbumListDestinationEnum: Hashable {
    case reviewDetail(AlbumReview)
    case albumDetail(Album)
}

