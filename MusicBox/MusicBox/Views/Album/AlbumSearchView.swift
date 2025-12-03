//
//  AlbumSearchView.swift
//  MusicBox
//
//  Created by Luca on 03/10/25.
//

import SwiftUI
import Combine

struct AlbumSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AlbumSearchViewModel()
    
    @ObservedObject var coordinator: AlbumSearchCoordinator

    @State private var isLoadingDetail = false

    var body: some View {
        VStack {
            HStack {
                Text("Search Albums")
                    .font(.system(size: 25, weight: .bold))
                    .padding(.vertical)
                    .padding(.leading)
                    .accessibilityIdentifier("albumSearchTitle")
                Spacer()
            }

            // 🔴 Add search field identifier
            HStack {
                TextField("Search Discogs albums...", text: $viewModel.searchText)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColorDark))
                    .accessibilityIdentifier("albumSearchField")
            }
            .padding(.horizontal)

            if viewModel.isSearching {
                ProgressView()
                    .padding()
                    .accessibilityIdentifier("albumSearchLoading")
            }

            // 🔴 Add identifier to List
            List {
                ForEach(viewModel.searchResults) { result in
                    VStack(alignment: .leading) {
                        AlbumComponentView(
                            album: .constant(dummyAlbum(from: result)),
                            remoteImageURL: result.thumb ?? result.cover_image
                        )
                        // 🔴 Add row identifier for UI tests
                        .accessibilityIdentifier("albumRow_\(result.id)")
                        .onTapGesture {
                            fetchDiscogsAlbum(id: result.id)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .accessibilityIdentifier("albumSearchResultsList")
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image(.musicboxLogo)
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("MusicBox")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(.systemRed)
                        .accessibilityIdentifier("albumSearchToolbarTitle")
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
    }

    private func dummyAlbum(from result: DiscogsSearchResult) -> Album {
        Album(
            id: " ",
            name: result.name,
            artist: result.artistName,
            year: result.year ?? "Unknown Year",
            image: nil
        )
    }

    private func fetchDiscogsAlbum(id: Int) {
        isLoadingDetail = true

        Task {
            do {
                let master = try await viewModel.discogsService.fetchMasterRelease(id: id)

                var albumImage: UIImage? = nil
                if let imageURL = master.images?.first(where: { $0.type == "primary" })?.uri,
                   let url = URL(string: imageURL) {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        albumImage = UIImage(data: data)
                    } catch {
                        print("❌ Failed to load image: \(error)")
                    }
                }

                let album = Album(
                    id: UUID().uuidString, // or use Discogs master ID
                    name: master.title,
                    artist: master.artists.first?.name ?? "Unknown Artist",
                    year: "\(master.year)",
                    image: albumImage
                )
                
                let songs = master.tracklist.enumerated().map { index, track in
                    Song(
                        id: UUID().uuidString, // generate a unique ID for this track
                        title: track.title,
                        trackNumber: index + 1,
                        duration: nil,         // optionally parse track.duration
                        album: album           // link to parent Album
                    )
                }

                album.songs = songs

                await MainActor.run {
                    coordinator.navigate(to: .albumDetail(album))
                    isLoadingDetail = false
                }

            } catch {
                await MainActor.run {
                    print("❌ Failed to fetch album: \(error)")
                    isLoadingDetail = false
                }
            }
        }
    }
}

