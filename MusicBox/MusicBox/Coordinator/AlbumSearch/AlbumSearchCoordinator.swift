//
//  AlbumSearchCoordinator.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

import Foundation
import SwiftUI

@MainActor
public class AlbumSearchCoordinator: ObservableObject {

    @Published public var path: [AlbumSearchDestinationEnum] = []
    @Published public var sheet: AlbumSearchSheetEnum? = nil
    @Published public var fullscreenCover: AlbumSearchFullscreenCoverEnum? = nil

    private let authenticationService: Authenticating
    private let userManager: UserFirestoreService

    init(authenticationService: Authenticating, userManager: UserFirestoreService) {
        self.authenticationService = authenticationService
        self.userManager = userManager
    }

    // MARK: - Navigation
    public func navigate(to screen: AlbumSearchDestinationEnum) {
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

    // MARK: - Presentation
    public func dismissPresentation() {
        sheet = nil
        fullscreenCover = nil
    }

    // MARK: - Builders
    func buildAlbumSearch() -> AnyView {
        AnyView(AlbumSearchView(coordinator: self))
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


    // MARK: - Router
    public func view(for state: AlbumSearchDestinationEnum) -> AnyView {
        switch state {
        case .albumDetail(let album):
            return buildAlbumDetail(album: album)
        }
    }

    // MARK: - Initial View
    public func showInitialView() -> AnyView {
        buildAlbumSearch()
    }
}
