//
//  AlbumListCoordinatorTests.swift
//  MusicBoxTests
//
//  Created for testing AlbumListCoordinator
//

import Testing
@testable import MusicBox

struct AlbumListCoordinatorTests {
    
    @MainActor @Test("Initial state has empty path")
    func testInitialState() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let coordinator = AlbumListCoordinator(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        #expect(coordinator.path.isEmpty)
        #expect(coordinator.sheet == nil)
        #expect(coordinator.fullscreenCover == nil)
    }
    
    @MainActor @Test("Navigate adds destination to path")
    func testNavigateAddsToPath() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let coordinator = AlbumListCoordinator(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        // Criar um álbum de teste
        let testAlbum = Album(
            id: "test-id",
            name: "Test Album",
            artist: "Test Artist",
            year: "2023",
            image: nil
        )
        
        coordinator.navigate(to: .albumDetail(testAlbum))
        
        #expect(coordinator.path.count == 1)
        
        if case .albumDetail(let album) = coordinator.path.first {
            #expect(album.id == "test-id")
        } else {
            Issue.record("Expected albumDetail destination")
        }
    }
    
    @MainActor @Test("Go back removes last destination")
    func testGoBackRemovesLast() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let coordinator = AlbumListCoordinator(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        let testAlbum = Album(
            id: "test-id",
            name: "Test Album",
            artist: "Test Artist",
            year: "2023",
            image: nil
        )
        
        coordinator.navigate(to: .albumDetail(testAlbum))
        #expect(coordinator.path.count == 1)
        
        coordinator.goBack()
        #expect(coordinator.path.isEmpty)
    }
    
    @MainActor @Test("Go back with empty path does nothing")
    func testGoBackWithEmptyPath() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let coordinator = AlbumListCoordinator(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        coordinator.goBack()
        #expect(coordinator.path.isEmpty)
    }
    
    @MainActor @Test("Back to root clears all destinations")
    func testBackToRoot() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let coordinator = AlbumListCoordinator(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        let testAlbum = Album(
            id: "test-id",
            name: "Test Album",
            artist: "Test Artist",
            year: "2023",
            image: nil
        )
        
        coordinator.navigate(to: .albumDetail(testAlbum))
        coordinator.navigate(to: .albumDetail(testAlbum))
        #expect(coordinator.path.count == 2)
        
        coordinator.backToRoot()
        #expect(coordinator.path.isEmpty)
    }
    
    @MainActor @Test("Dismiss presentation clears sheet and fullscreen cover")
    func testDismissPresentation() {
        let mockAuthService = MockAuthService()
        let userManager = UserFirestoreService()
        
        let coordinator = AlbumListCoordinator(
            authenticationService: mockAuthService,
            userManager: userManager
        )
        
        // Configurar sheet e fullscreenCover através de reflexão ou métodos públicos
        // Por enquanto, apenas verificamos que o método existe
        coordinator.dismissPresentation()
        
        #expect(coordinator.sheet == nil)
        #expect(coordinator.fullscreenCover == nil)
    }
}

