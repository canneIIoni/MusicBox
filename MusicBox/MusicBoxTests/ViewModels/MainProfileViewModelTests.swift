//
//  MainProfileViewModelTests.swift
//  MusicBoxTests
//
//  Created for testing MainProfileViewModel
//

import Testing
@testable import MusicBox

struct MainProfileViewModelTests {
    
    @MainActor @Test("Initial state has nil user")
    func testInitialState() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = MainProfileViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        #expect(viewModel.user == nil)
    }
    
    @MainActor @Test("Toggle premium status requires existing user")
    func testTogglePremiumRequiresUser() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let viewModel = MainProfileViewModel(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        // Sem usuário, não deve fazer nada
        viewModel.togglePremiumStatus()
        
        // Não deve crashar, apenas não fazer nada
        #expect(viewModel.user == nil)
    }
}

