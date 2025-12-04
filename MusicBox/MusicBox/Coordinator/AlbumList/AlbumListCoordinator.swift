//
//  AlbumListCoordinator.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

import Foundation
import SwiftUI

@MainActor
public class AlbumListCoordinator: ObservableObject {
    
    @Published public var path: [AlbumListDestinationEnum] = []
    @Published public var sheet: AlbumListSheetEnum? = nil
    @Published public var fullscreenCover: AlbumListFullscreenCoverEnum? = nil
    
    // Add stored dependencies
    private let authenticationService: Authenticating
    private let userManager: UserFirestoreService
    
    // Add initializer to accept dependencies
    init(authenticationService: Authenticating, userManager: UserFirestoreService) {
        self.authenticationService = authenticationService
        self.userManager = userManager
    }

    public func showInitialView() -> AnyView {
        buildAlbumList()
    }

    public func navigate(to screen: AlbumListDestinationEnum) {
        withAnimation {
            path.append(screen)
        }
    }

    func goBack() {
        if !path.isEmpty { path.removeLast() }
    }

    func backToRoot() {
        withAnimation { path.removeAll() }
    }

    public func dismissPresentation() {
        self.sheet = nil
        self.fullscreenCover = nil
    }

    func buildAlbumList() -> AnyView {
        AnyView(ReviewListView(coordinator: self))
    }

    // Update to use stored dependencies
    func buildAlbumDetail(album: Album) -> AnyView {
        let viewModel = AlbumDetailViewModel(
            authenticationService: authenticationService,
            userManager: userManager
        )
        return AnyView(AlbumDetailView(
            album: album,
            viewModel: viewModel,
            coordinator: self
        ))
    }

    func buildReviewDetail(albumReview: AlbumReview) -> AnyView {
        AnyView(ReviewDetailView(review: albumReview))
    }

    // Update to use stored dependencies
    @MainActor
    func view(for state: AlbumListDestinationEnum) -> AnyView {
        switch state {
        case .albumDetail(let album):
            return buildAlbumDetail(album: album)
        case .reviewDetail(let albumReview):
            return buildReviewDetail(albumReview: albumReview)
        }
    }
}
