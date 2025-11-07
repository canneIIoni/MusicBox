//
//  AlbumListView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//


import SwiftUI
import SwiftData

struct AlbumListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var albums: [Album] // Automatically fetches from SwiftData
    @State private var starSize: CGFloat = 25
    @State private var starEditable: Bool = false
    @State private var sortOption: SortOption = .dateLogged // Default sorting by date
    
    @ObservedObject var coordinator: AlbumListCoordinator

    enum SortOption: String, CaseIterable, Identifiable {
        case artist = "Artist"
        case album = "Album"
        case dateLogged = "Date Logged"

        var id: String { self.rawValue }
    }

    var sortedAlbums: [Album] {
        switch sortOption {
        case .artist:
            return albums.sorted { $0.artist.localizedCompare($1.artist) == .orderedAscending }
        case .album:
            return albums.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .dateLogged:
            return albums.sorted { $0.dateLogged ?? Date() > $1.dateLogged ?? Date() }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]), // Adjust colors here
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(alignment: .leading) {
                Text("Logged Albums")
                    .font(.system(size: 25, weight: .bold))
                    .padding(.vertical)
                    .padding(.leading)

                Picker("Sort by", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List {
                    ForEach(sortedAlbums) { album in
                        Button(action: {
                            coordinator.navigate(to: .albumDetail(album))
                        }) {
                            AlbumComponentView(album: .constant(album))
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteAlbum) // Enables swipe-to-delete
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image(.musicboxLogo)
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("Statik")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(.systemRed)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
//                    Notification Bell
            }
        }
        .onAppear {
            for album in albums {
                if !album.isLogged {
                    album.dateLogged = Date()
                }
            }
        }
    }

    private func deleteAlbum(at offsets: IndexSet) {
        for index in offsets {
            let albumToDelete = sortedAlbums[index]
            if let actualIndex = albums.firstIndex(where: { $0.id == albumToDelete.id }) {
                modelContext.delete(albums[actualIndex])
            }
        }
        try? modelContext.save()
    }
}

#Preview {
    AlbumListView(coordinator: AlbumListCoordinator())
        .modelContainer(for: Album.self, inMemory: true) // In-memory for preview
}
