//
//  MusicBoxCoordinator.swift
//  MusicBox
//
//  Created by Luca Lacerda on 03/10/25.
//

import Foundation
import SwiftUI

@MainActor
public class Coordinator: ObservableObject {

    @Published public var path:[DestinationEnum] = []
    @Published public var sheet: SheetEnum? = nil
    @Published public var fullscreenCover: FullscreenCoverEnum? = nil

    public func showInitalView() -> AnyView {
        buildSearch()
    }

    public func navigate(to screen: DestinationEnum) {
        withAnimation {
            path.append(screen)
        }
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func backToRoot() {
        withAnimation {
            path.removeAll()
        }
    }

    public func dismissPresentation() {
        self.sheet = nil
        self.fullscreenCover = nil
    }

    func buildSearch() -> AnyView {
        return AnyView(AlbumSearchView())
    }
    
    func buildAlbumDetail(albumId: Album) -> AnyView {
        return AnyView(AlbumDetailView(album: albumId))
    }

    public func view(for state: DestinationEnum) -> AnyView {
        switch state {
        case .search:
            return buildSearch()
            
        case .albumDetail(let album):
            return buildAlbumDetail(albumId: album)
        }
    }
}
