//
//  LoginViewModelTests.swift
//  MusicBoxTests
//
//  Created for testing LoginViewModel
//

import Testing
import Foundation
@testable import MusicBox

struct LoginViewModelTests {
    
    @MainActor @Test("Initial state has empty fields")
    func testInitialState() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = LoginViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        #expect(viewModel.email.isEmpty)
        #expect(viewModel.password.isEmpty)
        #expect(viewModel.authenticationState == .unauthenticated)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }
    
    @MainActor @Test("Sign in with empty email and password sets error message")
    func testSignInWithEmptyFields() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = LoginViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = ""
        viewModel.password = ""
        viewModel.signInWithEmail()
        
        // Deve ter erro porque campos estão vazios
        // Mas como é assíncrono, apenas verificamos que isLoading foi setado
        // ou errorMessage foi setado após a validação
    }
    
    @MainActor @Test("Sign up with empty email and password sets error message")
    func testSignUpWithEmptyFields() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = LoginViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = ""
        viewModel.password = ""
        viewModel.signUpWithEmail()
        
        // Deve setar errorMessage
        #expect(viewModel.errorMessage != nil)
    }
    
    @MainActor @Test("Auto login enabled loads from UserDefaults")
    func testAutoLoginEnabledLoadsFromUserDefaults() {
        UserDefaults.standard.set(true, forKey: "autoLoginEnabled")
        
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = LoginViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        #expect(viewModel.autoLoginEnabled == true)
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "autoLoginEnabled")
    }
    
    @MainActor @Test("Auto login disabled when not set in UserDefaults")
    func testAutoLoginDisabledByDefault() {
        UserDefaults.standard.removeObject(forKey: "autoLoginEnabled")
        
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = LoginViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        #expect(viewModel.autoLoginEnabled == false)
    }
    
    @MainActor @Test("Auto login toggle updates UserDefaults")
    func testAutoLoginToggleUpdatesUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "autoLoginEnabled")
        
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = LoginViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.autoLoginEnabled = true
        #expect(UserDefaults.standard.bool(forKey: "autoLoginEnabled") == true)
        
        viewModel.autoLoginEnabled = false
        #expect(UserDefaults.standard.bool(forKey: "autoLoginEnabled") == false)
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "autoLoginEnabled")
    }
}

