//
//  AlbumDetailView.swift
//  MusicBox
//
//  Created by Luca on 18/10/25.
//


//
//  AlbumDetailView.swift
//  Statik
//
//  Created by Luca on 28/02/25.
//


import SwiftUI
import SwiftData

struct AlbumDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var album: Album
    @State private var starSize: CGFloat = 25
    @State private var smallStarSize: CGFloat = 17
    @State private var starEditable: Bool = false
    @State private var imageSize: CGFloat = 147
    @State private var opacityValue: Double = 0.0
    
    var coordinator: AlbumListCoordinator?
    
    var isDuplicate: Bool {
        let name = album.name
        let artist = album.artist

        let fetchDescriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.name == name && $0.artist == artist && $0.isSaved == true }
        )

        let result = try? modelContext.fetch(fetchDescriptor)
        return !(result?.isEmpty ?? true)
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    
                    VStack {
                        ImageComponent(album: $album, imageSize: $imageSize)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Album · \(album.year ?? "Unknown Year")")
                            .font(.caption)
                            .foregroundStyle(.secondaryText)
                        
                        Text(album.name)
                            .font(.system(size: 25, weight: .bold))
                            .layoutPriority(1)
                        
                        Text(album.artist)
                            .font(.system(size: 16))
                        
                        if album.name.count < 36 {
                                HStack {
                                    RatingView(rating: $album.grade, starSize: $starSize, editable: $starEditable)
                                        .opacity(opacityValue)
                                        .transition(.opacity)
                                    if album.isLiked {
                                        Image(systemName: "heart.circle.fill")
                                            .resizable()
                                            .foregroundColor(.systemRed)
                                            .scaledToFit()
                                            .frame(width: starSize, height: starSize)
                                            .opacity(opacityValue)
                                            .transition(.opacity)
                                    } else {
                                        Image(systemName: "heart.circle")
                                            .resizable()
                                            .foregroundColor(.systemRed)
                                            .scaledToFit()
                                            .frame(width: starSize, height: starSize)
                                            .opacity(opacityValue)
                                            .transition(.opacity)
                                    }
                                }.padding(.top)
                                    .transition(.opacity)
                        }
                        
                        Spacer()
                    }
                        .padding(.top, 5).padding(.leading, 10)
                    
                    Spacer()
                }.padding(.top, 20)
                
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            if album.isLogged {
                                Text("Date Logged: \(returnDate(album.dateLogged ?? Date()))")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondaryText)
                                    .padding(.bottom, 5)
                            } else {
                                // Yes, I know this is horrible practice but I can't think straight right now
                                Text("Date Logged: \(returnDate(album.dateLogged ?? Date()))")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondaryText.opacity(opacityValue))
                                    .padding(.bottom, 5)
                            }
                            
                            if album.name.count >= 36 {
                                    HStack {
                                        RatingView(rating: $album.grade, starSize: $starSize, editable: $starEditable)
                                            .opacity(opacityValue)
                                            .transition(.opacity)
                                        if album.isLiked {
                                            Image(systemName: "heart.circle.fill")
                                                .resizable()
                                                .foregroundColor(.systemRed)
                                                .scaledToFit()
                                                .frame(width: starSize, height: starSize)
                                                .opacity(opacityValue)
                                                .transition(.opacity)
                                        } else {
                                            Image(systemName: "heart.circle")
                                                .resizable()
                                                .foregroundColor(.systemRed)
                                                .scaledToFit()
                                                .frame(width: starSize, height: starSize)
                                                .opacity(opacityValue)
                                                .transition(.opacity)
                                        }
                                    }.padding(.bottom, 5)
                                        .transition(.opacity)
                            }
                        }
                        Text(album.review)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondaryText)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    ForEach(album.songs.sorted { $0.trackNumber < $1.trackNumber }) { song in
                        if album.isSaved {
//                            NavigationLink(destination: SongDetailView(song: song, album: $album)) {
//                                SongComponentView(song: .constant(song), artist: .constant($album.wrappedValue.artist), smallStarSize: .constant(17))
//                                    .padding(.vertical, 8)
//                                    .transition(.opacity)
//                            }
                        } else {
                            SearchedSongComponentView(song: .constant(song), artist: .constant($album.wrappedValue.artist), smallStarSize: .constant(17))
                                .padding(.vertical, 8)
                                .transition(.opacity)
                        }

                    }
                }
                .padding(.trailing)
            }.padding(.leading, 15)

        }
        .onAppear {
            opacityValue = album.isSaved ? 1.0 : 0.0
        }
        .onChange(of: album.isSaved, { oldValue, newValue in
            withAnimation {
                opacityValue = newValue ? 1.0 : 0.0
            }
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if album.isSaved {
//                    NavigationLink(destination: AlbumReviewView(album: $album)) {
//                        Text("Log")
//                            .font(.system(size: 18, weight: .bold))
//                            .foregroundStyle(.systemRed)
//                    }.transition(.opacity)
                } else {
                    Button {
                        withAnimation {
                            opacityValue = 1
                        }
                        album.dateLogged = Date()
                        withAnimation {
                            album.isLogged = true
                        }
                        withAnimation {
                            album.isSaved = true
                        }
                        modelContext.insert(album)
                        try? modelContext.save()
                    } label: {
                        Text("Save")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(isDuplicate ? .gray : .systemRed)
                    }
                    .disabled(isDuplicate)
                    .transition(.opacity)
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]), // Adjust colors here
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
        .onDisappear {
            try? modelContext.save()
        }
    }
    
    func returnDate (_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        
        return dateFormatter.string(from: album.dateLogged ?? Date())
    }
    
    
}
