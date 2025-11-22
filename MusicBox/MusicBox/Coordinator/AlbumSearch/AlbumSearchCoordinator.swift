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
    
    public func showInitialView() -> AnyView {
        buildAlbumSearch()
    }
    
    public func navigate(to screen: AlbumSearchDestinationEnum) {
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
    
    func buildAlbumSearch() -> AnyView {
        return AnyView(AlbumSearchView(coordinator: self))
    }
    
    func buildAlbumDetail(album: Album) -> AnyView {
        return AnyView(AlbumDetailView(album: album, coordinator: nil))
    }
    
    public func view(for state: AlbumSearchDestinationEnum) -> AnyView {
        switch state {
        case .albumDetail(let album):
            return buildAlbumDetail(album: album)
        }
    }
}

