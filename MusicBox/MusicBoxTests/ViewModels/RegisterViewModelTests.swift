//
//  RegisterViewModelTests.swift
//  MusicBoxTests
//
//  Created for testing RegisterViewModel
//

import Testing
@testable import MusicBox

struct RegisterViewModelTests {
    
    @MainActor @Test("Initial state has empty fields")
    func testInitialState() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        #expect(viewModel.email.isEmpty)
        #expect(viewModel.password.isEmpty)
        #expect(viewModel.confirmPassword.isEmpty)
        #expect(viewModel.displayName.isEmpty)
        #expect(viewModel.authenticationState == .unauthenticated)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }
    
    @MainActor @Test("Email validation accepts valid email")
    func testEmailValidationValid() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = "test@example.com"
        #expect(viewModel.isEmailValid == true)
    }
    
    @MainActor @Test("Email validation rejects invalid email without @")
    func testEmailValidationInvalidNoAt() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = "testexample.com"
        #expect(viewModel.isEmailValid == false)
    }
    
    @MainActor @Test("Email validation rejects invalid email without dot")
    func testEmailValidationInvalidNoDot() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = "test@example"
        #expect(viewModel.isEmailValid == false)
    }
    
    @MainActor @Test("Email validation rejects empty email")
    func testEmailValidationEmpty() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = ""
        #expect(viewModel.isEmailValid == false)
    }
    
    @MainActor @Test("Password validation accepts valid password")
    func testPasswordValidationValid() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.password = "password123"
        #expect(viewModel.isPasswordValid == true)
    }
    
    @MainActor @Test("Password validation accepts minimum length")
    func testPasswordValidationMinimumLength() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.password = "123456" // Exactly 6 characters
        #expect(viewModel.isPasswordValid == true)
    }
    
    @MainActor @Test("Password validation rejects short password")
    func testPasswordValidationTooShort() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.password = "12345" // Less than 6 characters
        #expect(viewModel.isPasswordValid == false)
    }
    
    @MainActor @Test("Password match validation when passwords match")
    func testPasswordMatchWhenMatching() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        #expect(viewModel.doPasswordsMatch == true)
    }
    
    @MainActor @Test("Password match validation when passwords don't match")
    func testPasswordMatchWhenNotMatching() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.password = "password123"
        viewModel.confirmPassword = "different456"
        #expect(viewModel.doPasswordsMatch == false)
    }
    
    @MainActor @Test("Password match validation when confirm password is empty")
    func testPasswordMatchWhenConfirmEmpty() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.password = "password123"
        viewModel.confirmPassword = ""
        #expect(viewModel.doPasswordsMatch == true) // Allows empty during typing
    }
    
    @MainActor @Test("Can sign up when all validations pass")
    func testCanSignUpWhenValid() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.isLoading = false
        
        #expect(viewModel.canSignUp == true)
    }
    
    @MainActor @Test("Cannot sign up when email is invalid")
    func testCannotSignUpWithInvalidEmail() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = "invalid-email"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        #expect(viewModel.canSignUp == false)
    }
    
    @MainActor @Test("Cannot sign up when password is too short")
    func testCannotSignUpWithShortPassword() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = "test@example.com"
        viewModel.password = "12345"
        viewModel.confirmPassword = "12345"
        
        #expect(viewModel.canSignUp == false)
    }
    
    @MainActor @Test("Cannot sign up when passwords don't match")
    func testCannotSignUpWhenPasswordsDontMatch() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "different456"
        
        #expect(viewModel.canSignUp == false)
    }
    
    @MainActor @Test("Cannot sign up when loading")
    func testCannotSignUpWhenLoading() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = RegisterViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        viewModel.isLoading = true
        
        #expect(viewModel.canSignUp == false)
    }
}

