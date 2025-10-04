//
//  FullscreenCoverEnum.swift
//  MusicBox
//
//  Created by Luca Lacerda on 03/10/25.
//

public enum FullscreenCoverEnum: Identifiable {
    case full1

    public var id: String {
        switch self {
        case .full1:
            return "1"
        }
    }
}
