//
//  CoordinatorView.swift
//  MusicBox
//
//  Created by Luca Lacerda on 03/10/25.
//

import Foundation
import SwiftUI

public struct CoordinatorView: View {

    @ObservedObject var coordinator: Coordinator

    public init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.showInitalView()
                .navigationDestination(for: DestinationEnum.self) { state in
                    coordinator.view(for: state)
                }
        }.sheet(item: $coordinator.sheet) { sheetOption in
            //adicionar sheets aqui
            switch sheetOption {
            case .sheet1:
                Text("sheet1")
            }
        }
        .fullScreenCover(item: $coordinator.fullscreenCover) { option in
            //fullScreen aqui
            switch option {
            case .full1:
                Text("full1")
            }
        }
    }
}
