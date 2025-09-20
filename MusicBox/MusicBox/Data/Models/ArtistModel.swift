import Foundation

// MARK: - Artist
class Artist {
    var id: UUID
    var name: String
    var bio: String
    var genres: [String]
    var imageData: Data?

    // Relacionamentos
    var albums: [Album]

    init(id: UUID = UUID(),
         name: String,
         bio: String,
         genres: [String],
         imageData: Data? = nil,
         albums: [Album] = []) {

        self.id = id
        self.name = name
        self.bio = bio
        self.genres = genres
        self.imageData = imageData
        self.albums = albums
    }
}
