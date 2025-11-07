//
//  AlbumTabView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//


import SwiftUI

struct AlbumTabView: View {
    @StateObject private var albumListCoordinator = AlbumListCoordinator()
    @StateObject private var albumSearchCoordinator = AlbumSearchCoordinator()
    
    var body: some View {
        TabView {
            AlbumListCoordinatorView(coordinator: albumListCoordinator)
                .tabItem {
                    Label("My Albums", systemImage: "music.note.list")
                }

            AlbumSearchCoordinatorView(coordinator: albumSearchCoordinator)
                .tabItem {
                    Label("Search Discogs", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    AlbumTabView()
}