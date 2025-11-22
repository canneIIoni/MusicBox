//
//  RegisterView.swift
//  MusicBox
//
//  Created by Luca Lacerda on 07/11/25.
//

import SwiftUI

struct RegisterView: View {
    
    @ObservedObject var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Logo and Title
                VStack(spacing: 16) {
                    Image(.musicboxLogo)
                        .resizable()
                        .frame(width: 80, height: 80)
                    
                    Text("MusicBox")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.systemRed)
                    
                    Text("Create your account")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.secondaryText)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                if viewModel.authenticationState == .unauthenticated {
                    
                    // Display Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondaryText)
                        
                        TextField("Enter your name", text: $viewModel.displayName)
                            .textContentType(.name)
                            .autocapitalization(.words)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.backgroundColorDark)
                            )
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondaryText)
                        
                        TextField("Enter your email", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.backgroundColorDark)
                            )
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondaryText)
                        
                        SecureField("Enter your password", text: $viewModel.password)
                            .textContentType(.newPassword)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.backgroundColorDark)
                            )
                        
                        if !viewModel.isPasswordValid && !viewModel.password.isEmpty {
                            Text("Password must be at least 6 characters")
                                .font(.system(size: 12))
                                .foregroundStyle(.systemRed)
                                .padding(.top, 4)
                        }
                    }
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondaryText)
                        
                        SecureField("Confirm your password", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.backgroundColorDark)
                            )
                        
                        if !viewModel.doPasswordsMatch && !viewModel.confirmPassword.isEmpty {
                            Text("Passwords do not match")
                                .font(.system(size: 12))
                                .foregroundStyle(.systemRed)
                                .padding(.top, 4)
                        }
                    }
                    
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(.systemRed)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Sign Up Button
                    Button {
                        viewModel.signUpWithEmail()
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
                                    .font(.system(size: 18, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.canSignUp && !viewModel.isLoading ? Color.systemRed : Color.gray)
                        )
                        .foregroundStyle(.white)
                    }
                    .disabled(!viewModel.canSignUp || viewModel.isLoading)
                    .padding(.top, 8)
                    
                    // Sign In Link
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondaryText)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Sign In")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.systemRed)
                        }
                    }
                    .padding(.top, 16)
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Creating account...")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondaryText)
                    }
                    .padding(.top, 100)
                }
                
                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.backgroundColorDark, Color.background]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundStyle(.systemRed)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView(viewModel: RegisterViewModel(
            authenticationService: FirebaseAuthService(),
            userManager: UserFirestoreService()
        ))
    }
}

