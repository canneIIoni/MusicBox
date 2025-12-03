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
    
    public var userId: String
    public var username: String?

    public init(userId: String, username: String?) {
        self.userId = userId
        self.username = username
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
        AnyView(AlbumDetailView(album: album, userId: userId, username: username, coordinator: nil))
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
