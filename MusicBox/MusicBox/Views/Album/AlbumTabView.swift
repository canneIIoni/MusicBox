//
//  AlbumTabView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//


import SwiftUI

struct AlbumTabView: View {
    var body: some View {
        TabView {
            AlbumListView()
                .tabItem {
                    Label("My Albums", systemImage: "music.note.list")
                }

            AlbumSearchView()
                .tabItem {
                    Label("Search Discogs", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    AlbumTabView()
}