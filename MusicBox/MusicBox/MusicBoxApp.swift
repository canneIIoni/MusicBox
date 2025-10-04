//
//  MusicBoxApp.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import SwiftUI
import SwiftData

@main
struct MusicBoxApp: App {
    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: Coordinator())
        }
        .modelContainer(for: Album.self)
    }
}
