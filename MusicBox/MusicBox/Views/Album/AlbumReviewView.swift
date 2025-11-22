//
//  AlbumReviewView.swift
//  MusicBox
//
//  Created by Luca on 22/11/25.
//


import SwiftUI

struct AlbumReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var album: Album
    @State private var starSize: CGFloat = 37
    @State private var starEditable: Bool = true
    @State private var review: String = ""
    @State private var rating: Double = 0
    @State private var showWarning = false
    @State private var imageSize: CGFloat = 65
    
    var body: some View {
        VStack {
            HStack {
                
                ImageComponent(album: $album, imageSize: $imageSize)
                
                VStack(alignment: .leading) {
                    Text("Album · \(album.year ?? "Unknown Year")")
                        .font(.caption)
                        .foregroundStyle(.secondaryText)
                    Text(album.name)
                        .font(.title2)
                        .bold()
                    Text(album.artist)
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
                    RatingView(rating: $album.grade, starSize: $starSize, editable: $starEditable)
                }.padding(.bottom)
                
                Spacer()
                
                VStack(alignment: .center) {
                    if album.isLiked {
                        Text("Liked").font(.system(size: 16, weight: .bold))
                    } else {
                        Text("Like").font(.system(size: 16, weight: .bold))
                    }
                    Button(action: toggleLike) {
                        Image(systemName: album.isLiked ? "heart.circle.fill" : "heart.circle")
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
                    print(album.review)
                    print(review)
                    print(album.grade)
                    print(rating)
                    if album.review != review || album.grade != rating {
                        showWarning = true
                    } else {
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
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy"
                    album.review = review
                    rating = album.grade
                    album.dateLogged = Date()
                    album.isLogged = true
                    try? modelContext.save() // Ensure Core Data saves the changes
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
                review = album.review
                album.grade = rating
                try? modelContext.save()
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
            album.review = review
            album.grade = rating
            try? modelContext.save()
        }
        .onAppear {
            review = album.review
            rating = album.grade
        }
    }

    private func toggleLike() {
        album.isLiked.toggle()
    }
}