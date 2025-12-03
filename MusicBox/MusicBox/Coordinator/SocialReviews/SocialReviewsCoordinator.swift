//
//  SocialReviewsCoordinator.swift
//  MusicBox
//
//  Created by Luca on 03/12/25.
//


//
//  SocialReviewsCoordinator.swift
//  MusicBox
//

import Foundation
import SwiftUI

@MainActor
public class SocialReviewsCoordinator: ObservableObject {

    @Published public var path: [SocialReviewsDestinationEnum] = []
    @Published public var sheet: SocialReviewsSheetEnum? = nil
    @Published public var fullscreenCover: SocialReviewsFullscreenCoverEnum? = nil

    public init() {}

    // MARK: - Navigation

    public func navigate(to screen: SocialReviewsDestinationEnum) {
        withAnimation {
            path.append(screen)
        }
    }

    public func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    public func backToRoot() {
        withAnimation {
            path.removeAll()
        }
    }

    // MARK: - Presentation

    public func dismissPresentation() {
        sheet = nil
        fullscreenCover = nil
    }

    // MARK: - Builders

    func buildSocialReviews() -> AnyView {
        AnyView(SocialReviewsView(coordinator: self))
    }

    func buildAlbumDetail(album: Album) -> AnyView {
        AnyView(AlbumDetailView(album: album, coordinator: nil))
    }

    // MARK: - Router

    public func view(for state: SocialReviewsDestinationEnum) -> AnyView {
        switch state {
        case .albumDetail(let album):
            return buildAlbumDetail(album: album)
        }
    }
}
