//
//  SocialReviewsCoordinatorView.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//


//
//  SocialReviewsCoordinatorView.swift
//  MusicBox
//

import SwiftUI

public struct SocialReviewsCoordinatorView: View {
    @ObservedObject var coordinator: SocialReviewsCoordinator

    public init(coordinator: SocialReviewsCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.buildSocialReviews()
                .navigationDestination(for: SocialReviewsDestinationEnum.self) { destination in
                    coordinator.view(for: destination)
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .placeholder:
                Text("Placeholder Sheet")
            }
        }
        .fullScreenCover(item: $coordinator.fullscreenCover) { cover in
            switch cover {
            case .placeholder:
                Text("Placeholder Fullscreen Cover")
            }
        }
    }
}
