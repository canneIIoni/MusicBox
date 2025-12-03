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
        return AnyView(ReviewListView(coordinator: self))
    }
    
    func buildAlbumDetail(album: Album, userId: String, username: String?) -> AnyView {
        AnyView(AlbumDetailView(album: album, userId: userId, username: username, coordinator: self))
    }
    
    func buildReviewDetail(albumReview: AlbumReview) -> AnyView {
        AnyView(ReviewDetailView(review: albumReview))
    }
    
    /// Updated to accept user info and return the correct view
    public func view(for state: AlbumListDestinationEnum, userId: String? = nil, username: String? = nil) -> AnyView {
        switch state {
        case .albumDetail(let album):
            guard let userId else {
                fatalError("userId must be provided for AlbumDetailView")
            }
            return buildAlbumDetail(album: album, userId: userId, username: username)
            
        case .reviewDetail(let albumReview):
            return buildReviewDetail(albumReview: albumReview)
        }
    }
}

