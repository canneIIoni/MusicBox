//
//  LoginView.swift
//  MusicBox
//
//  Created by Mateus Martins Pires on 31/10/25.
//
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 64) {
            
            if viewModel.authenticationState == .unauthenticated {
                
                VStack(spacing: 12){
                    TextField("Email...", text: $viewModel.email)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    SecureField("Password...", text: $viewModel.password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                VStack(spacing: 24) {
                    Button {
                        // Test login
                        viewModel.signUpWithEmail()
                    } label: {
                        Text("Sign Up")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                    .disabled(true)
                   // .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 70)
                    .padding(.vertical, 12)
                    .background(.systemRed, in: .rect(cornerRadius: 12))

                    
                    Button {
                        // Test login
                        viewModel.signInWithEmail()
                    } label: {
                        Text("Log In")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                    .disabled(true)
                    //.buttonStyle(.borderedProminent)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 80)
                    .background(.systemRed, in: .rect(cornerRadius: 12))
                }
            } else {
                Text("Logged")
            }
           
        }
        .padding()
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(authenticationService: FirebaseAuthService(), userManager: UserFirestoreService()))
}
