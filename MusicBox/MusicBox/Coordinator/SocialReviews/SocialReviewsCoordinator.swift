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
    
    private let authenticationService: Authenticating
    private let userManager: UserFirestoreService
    
    init(authenticationService: Authenticating, userManager: UserFirestoreService) {
        self.authenticationService = authenticationService
        self.userManager = userManager
    }

    public func navigate(to screen: SocialReviewsDestinationEnum) { withAnimation { path.append(screen) } }
    public func goBack() { if !path.isEmpty { path.removeLast() } }
    public func backToRoot() { withAnimation { path.removeAll() } }
    public func dismissPresentation() { sheet = nil; fullscreenCover = nil }

    // MARK: - View Builders
    
    func buildSocialReviews() -> AnyView {
        AnyView(SocialReviewsView(coordinator: self))
    }
    
    func buildAlbumDetail(album: Album) -> AnyView {
        let viewModel = AlbumDetailViewModel(
            authenticationService: authenticationService,
            userManager: userManager
        )
        
        return AnyView(
            AlbumDetailView(
                album: album,
                viewModel: viewModel,
                coordinator: nil
            )
        )
    }
    
    func buildReviewDetail(review: AlbumReview) -> AnyView {
        AnyView(ReviewDetailView(review: review))
    }

    // MARK: - Destination View Handler
    
    @ViewBuilder
    public func view(for destination: SocialReviewsDestinationEnum) -> some View {
        switch destination {
        case .reviewDetail(let review):
            buildReviewDetail(review: review)
            
        // Add other cases as needed
        // case .albumDetail(let album):
        //     buildAlbumDetail(album: album)
        }
    }

    public func showInitialView() -> AnyView { buildSocialReviews() }
}
