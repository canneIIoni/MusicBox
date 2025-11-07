//
//  AlbumSearchCoordinatorView.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

import Foundation
import SwiftUI

public struct AlbumSearchCoordinatorView: View {
    
    @ObservedObject var coordinator: AlbumSearchCoordinator
    
    public init(coordinator: AlbumSearchCoordinator) {
        self.coordinator = coordinator
    }
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.showInitialView()
                .navigationDestination(for: AlbumSearchDestinationEnum.self) { state in
                    coordinator.view(for: state)
                }
        }
        .sheet(item: $coordinator.sheet) { sheetOption in
            switch sheetOption {
            case .placeholder:
                Text("Placeholder")
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

