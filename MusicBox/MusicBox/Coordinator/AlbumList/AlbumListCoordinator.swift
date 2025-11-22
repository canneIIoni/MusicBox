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
    
    public func showInitialView() -> AnyView {
        buildAlbumList()
    }
    
    public func navigate(to screen: AlbumListDestinationEnum) {
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
    
    func buildAlbumList() -> AnyView {
        return AnyView(AlbumListView(coordinator: self))
    }
    
    func buildAlbumDetail(album: Album) -> AnyView {
        return AnyView(AlbumDetailView(album: album, coordinator: self))
    }
    
    public func view(for state: AlbumListDestinationEnum) -> AnyView {
        switch state {
        case .albumDetail(let album):
            return buildAlbumDetail(album: album)
        }
    }
}

