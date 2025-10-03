//import SwiftUI
//
//struct ContentView: View {
//    var networkManager = NetworkingManager.shared
//    let releaseId = 4289546 // ID de exemplo para testar
//
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Detalhes do Release")
//        }
//        .padding()
//        .onAppear {
//            Task {
//                do {
//                    let album = try await networkManager.request(
//                        session: .shared,
//                        .release(id: releaseId),
//                        type: Album.self
//                    )
//                    print("Album: \(album.name)")
//
//                    print("Ano: \(album.year)")
//
//                } catch {
//                    print("Request failed: \(error)")
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
