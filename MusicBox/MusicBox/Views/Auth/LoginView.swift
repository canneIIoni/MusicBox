//
//  LoginView.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    
                    Spacer().frame(height: 20)

                    Image("TextLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.horizontal, 20)
                    
                    Text("Welcome back!")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.secondaryText)
                }
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                if viewModel.authenticationState == .unauthenticated {
                    
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
                            .accessibilityIdentifier("loginEmailField")
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondaryText)
                        
                        SecureField("Enter your password", text: $viewModel.password)
                            .textContentType(.password)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.backgroundColorDark)
                            )
                            .accessibilityIdentifier("loginPasswordField")
                    }
                    
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(.systemRed)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    // MARK: - Auto Login Checkbox
                                    Toggle(isOn: $viewModel.autoLoginEnabled) {
                                        Text("Keep me logged in")
                                    }
                                    .accessibilityIdentifier("autoLoginToggle")
                    
                    // Log In Button
                    Button {
                        viewModel.signInWithEmail()
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Log In")
                                    .font(.system(size: 18, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill((viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading) ? Color.gray : Color.systemRed)
                        )
                        .foregroundStyle(.white)
                    }
                    .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                    .padding(.top, 20)
                    .accessibilityIdentifier("loginButton")
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondaryText)
                        
                        NavigationLink(destination: RegisterViewWrapper(authenticationService: viewModel.authenticationService as! FirebaseAuthService)) {
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.systemRed)
                        }
                    }
                    .padding(.top, 16)
                    
                    // Debug Login Button (only in debug mode)
                    if DebugConfig.enableDebugLogin {
                        Divider()
                            .padding(.vertical, 16)
                        
                        Button {
                            viewModel.loginWithHardcodedUser()
                        } label: {
                            HStack {
                                Image(systemName: "wrench.and.screwdriver")
                                Text("Debug: Login as Test User")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundStyle(.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondaryText.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Logging in...")
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
        }
    }
}

struct RegisterViewWrapper: View {
    @ObservedObject var authenticationService: FirebaseAuthService
    @StateObject private var registerViewModel: RegisterViewModel
    
    init(authenticationService: FirebaseAuthService) {
        self.authenticationService = authenticationService
        let userManager = UserFirestoreService()
        self._registerViewModel = StateObject(wrappedValue: RegisterViewModel(
            authenticationService: authenticationService,
            userManager: userManager
        ))
    }
    
    var body: some View {
        RegisterView(viewModel: registerViewModel)
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(authenticationService: FirebaseAuthService(), userManager: UserFirestoreService()))
}
