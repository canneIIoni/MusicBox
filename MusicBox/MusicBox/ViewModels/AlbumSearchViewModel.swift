//
//  AlbumSearchViewModel.swift
//  Statik
//
//  Created by Luca on 02/05/25.
//


import Foundation
import Combine

@MainActor
class AlbumSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [DiscogsSearchResult] = []
    @Published var isSearching = false

    let discogsService = DiscogsService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                Task { await self.performSearch(for: text) }
            }
            .store(in: &cancellables)
    }

    func performSearch(for text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        do {
            let results = try await discogsService.searchAlbums(query: trimmed)
            searchResults = results
        } catch {
            print("❌ Search failed: \(error)")
            searchResults = []
        }
        isSearching = false
    }
}
