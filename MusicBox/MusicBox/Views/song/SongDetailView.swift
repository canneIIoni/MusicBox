//
//  SongDetailView.swift
//  Statik
//
//  Created by Luca on 28/02/25.
//


import SwiftUI

struct SongDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var song: Song
    @Binding var album: Album
    @State private var starSize: CGFloat = 37
    @State private var starEditable: Bool = true
    @State private var review: String = ""
    @State private var rating: Double = 0
    @State private var like: Bool = false
    @State private var showWarning = false

    var body: some View {
        VStack {
            HStack {
                if let image = album.albumImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 65, height: 65)
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 65, height: 65)
                        .overlay(Text("No Image").foregroundColor(.gray))
                }
                VStack(alignment: .leading) {
                    Text("\(album.artist) · \(album.year ?? "Unknown Year")")
                        .font(.caption)
                        .foregroundStyle(.secondaryText)
                    Text(song.title)
                        .font(.title2)
                        .bold()
                    Text(album.name)
                        .font(.system(size: 16))
                    Spacer()
                }.frame(height: 65)
                
                Spacer()
            }
            .padding(.bottom)
            
            Divider().padding(.bottom)

            HStack {
                VStack(alignment: .leading) {
                    Text("Rating")
                        .font(.system(size: 16, weight: .bold))
                    RatingView(rating: $song.grade, starSize: $starSize, editable: $starEditable)
                }.padding(.bottom)
                
                Spacer()
                
                VStack(alignment: .center) {
                    if song.isLiked {
                        Text("Liked").font(.system(size: 16, weight: .bold))
                    } else {
                        Text("Like").font(.system(size: 16, weight: .bold))
                    }
                    Button(action: toggleLike) {
                        Image(systemName: song.isLiked ? "heart.circle.fill" : "heart.circle")
                            .foregroundColor(.systemRed)
                            .font(.system(size: 37, weight: .bold))
                    }.offset(y: 4)
                }.padding(.bottom)
                    
            }
            
            Divider().padding(.bottom)
            
            HStack {
                Text("Review")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }

            TextField("", text: $review, prompt: Text("Write a review..."), axis: .vertical)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColorDark))
                .lineLimit(6, reservesSpace: true)
                

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if song.review != review || song.grade != rating {
                        showWarning = true
                    } else {
                        song.grade = rating
                        dismiss()
                    }
                    
                } label: {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.secondaryText)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    song.review = review
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.systemRed)
                }
            }
            
        }.alert("Are you sure?", isPresented: $showWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm", role: .destructive) {
                song.grade = rating
                dismiss()
            }
        } message: {
            Text("Unsaved changes might be lost.")
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
            if let index = album.songs.firstIndex(where: { $0.id == song.id }) {
                album.songs[index] = song
            }
            
        }
        .onAppear {
            review = song.review.isEmpty ? "" : song.review
            rating = song.grade
        }
    }

    private func toggleLike() {
        song.isLiked.toggle()
    }
}
