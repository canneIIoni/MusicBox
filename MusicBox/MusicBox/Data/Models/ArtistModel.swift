import Foundation

// MARK: - Artist
struct Artist: Codable {
    var id: UUID
    var name: String
    var bio: String
    var genres: [String]
    var imageData: Data?

    // Relacionamentos
    var albums: [Album]
}
