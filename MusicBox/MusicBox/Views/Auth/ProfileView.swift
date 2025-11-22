//
//  ProfileView.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//

import SwiftUI

struct MainProfileView: View {
    
    @StateObject var viewModel: MainProfileViewModel
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header Section
                    VStack(spacing: 20) {
                        // Profile Icon
                        ZStack {
                            Circle()
                                .fill(Color.backgroundColorDark)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.systemRed)
                        }
                        .padding(.top, 40)
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text(viewModel.user?.email ?? "No email found")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            if let user = viewModel.user {
                                Text("User ID: \(user.userId.prefix(8))...")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondaryText)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Premium Status Card
//                    if let user = viewModel.user, let isPremium = user.isPremium {
//                        VStack(spacing: 16) {
//                            HStack {
//                                VStack(alignment: .leading, spacing: 8) {
//                                    HStack {
//                                        Image(systemName: isPremium ? "crown.fill" : "crown")
//                                            .foregroundStyle(isPremium ? .systemRed : .secondaryText)
//                                        Text("Premium Status")
//                                            .font(.system(size: 18, weight: .semibold))
//                                            .foregroundStyle(.primary)
//                                    }
//                                    
//                                    Text(isPremium ? "Premium Member" : "Free Member")
//                                        .font(.system(size: 14))
//                                        .foregroundStyle(.secondaryText)
//                                }
//                                
//                                Spacer()
//                                
//                                Button {
//                                    viewModel.togglePremiumStatus()
//                                } label: {
//                                    Text(isPremium ? "Premium" : "Free")
//                                        .font(.system(size: 14, weight: .bold))
//                                        .foregroundStyle(.white)
//                                        .padding(.horizontal, 20)
//                                        .padding(.vertical, 10)
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 8)
//                                                .fill(isPremium ? Color.systemRed : Color.gray)
//                                        )
//                                }
//                            }
//                            .padding(20)
//                            .background(
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(Color.backgroundColorDark)
//                            )
//                        }
//                        .padding(.horizontal, 24)
//                    }
                    
                    // Account Actions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            // Reset Password Button
                            Button {
                                viewModel.resetPassword()
                            } label: {
                                HStack {
                                    Image(systemName: "key.fill")
                                        .foregroundStyle(.systemRed)
                                        .frame(width: 24)
                                    
                                    Text("Reset Password")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.secondaryText)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.backgroundColorDark)
                                )
                            }
                            
                            // Log Out Button
                            Button {
                                viewModel.signOut()
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundStyle(.systemRed)
                                        .frame(width: 24)
                                    
                                    Text("Log Out")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.secondaryText)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.backgroundColorDark)
                                )
                            }
                            
                            // Delete Account Button
                            Button {
                                viewModel.deleteAccount()
                            } label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundStyle(.red)
                                        .frame(width: 24)
                                    
                                    Text("Delete Account")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.red)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.secondaryText)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.backgroundColorDark)
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 20)
                    
                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image(.musicboxLogo)
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("Music Box")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(.systemRed)
                }
            }
        }
        .task {
            isLoading = true
            try? await viewModel.loadCurrentUser()
            isLoading = false
        }
        .overlay {
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .systemRed))
                    Text("Loading profile...")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondaryText)
                        .padding(.top, 8)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.backgroundColorDark)
                )
            }
        }
    }
}

#Preview {
    MainProfileView(viewModel: MainProfileViewModel(authenticationService: FirebaseAuthService(), userManager: UserFirestoreService()))
}
