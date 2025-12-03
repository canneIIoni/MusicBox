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

    public var userId: String
    public var username: String?

    public init(userId: String, username: String?) {
        self.userId = userId
        self.username = username
    }

    // MARK: - Navigation
    public func navigate(to screen: SocialReviewsDestinationEnum) {
        withAnimation { path.append(screen) }
    }

    public func goBack() {
        if !path.isEmpty { path.removeLast() }
    }

    public func backToRoot() {
        withAnimation { path.removeAll() }
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
        AnyView(AlbumDetailView(album: album, userId: userId, username: username, coordinator: nil))
    }

    func buildReviewDetail(review: AlbumReview) -> AnyView {
        AnyView(ReviewDetailView(review: review))
    }

    // MARK: - Router
    public func view(for state: SocialReviewsDestinationEnum) -> AnyView {
        switch state {
        case .reviewDetail(let review):
            return buildReviewDetail(review: review)
        }
    }

    // MARK: - Initial View
    public func showInitialView() -> AnyView {
        buildSocialReviews()
    }
}
