//
//  AlbumListCoordinatorView.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

import Foundation
import SwiftUI

public struct AlbumListCoordinatorView: View {
    
    @ObservedObject var coordinator: AlbumListCoordinator
    
    public init(coordinator: AlbumListCoordinator) {
        self.coordinator = coordinator
    }
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.showInitialView()
                .navigationDestination(for: AlbumListDestinationEnum.self) { state in
                    coordinator.view(for: state)
                }
        }
        .sheet(item: $coordinator.sheet) { sheetOption in
            switch sheetOption {
            case .addAlbum:
                Text("Add Album")
            }
        }
        .fullScreenCover(item: $coordinator.fullscreenCover) { option in
            switch option {
            case .placeholder:
                Text("Placeholder")
            }
        }
    }
}

