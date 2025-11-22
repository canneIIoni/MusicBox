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
                Spacer()
            }
            HStack {
                TextField("Search Discogs albums...", text: $viewModel.searchText)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColorDark))
            }
            .padding(.horizontal)

            if viewModel.isSearching {
                ProgressView()
                    .padding()
            }

            List {
                ForEach(viewModel.searchResults) { result in
                    VStack(alignment: .leading) {
                        AlbumComponentView(
                            album: .constant(dummyAlbum(from: result)),
                            remoteImageURL: result.thumb ?? result.cover_image
                        )
                        .onTapGesture {
                            fetchDiscogsAlbum(id: result.id)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
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
            name: result.name,
            artist: result.artistName,
            year: result.year ?? "Unknown Year",
            review: "",
            isLiked: false,
            grade: 0.0,
            image: nil,
            songs: [],
            dateLogged: Date()
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

                let songs = master.tracklist.enumerated().map { index, track in
                    Song(title: track.title, isLiked: false, grade: 0.0, review: "", trackNumber: index + 1)
                }

                let album = Album(
                    name: master.title,
                    artist: master.artists.first?.name ?? "Unknown Artist",
                    year: "\(master.year)",
                    review: "",
                    isLiked: false,
                    grade: 0.0,
                    image: albumImage,
                    songs: songs,
                    dateLogged: Date()
                )

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

#Preview {
    AlbumSearchView(coordinator: AlbumSearchCoordinator())
}

