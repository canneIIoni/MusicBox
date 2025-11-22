//
//  MusicBoxApp.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Configure Firebase only if not already configured
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    return true
  }
}


@main
struct MusicBoxApp: App {
    // Firebase Configuration
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authenticationService = FirebaseAuthService()
    
    var body: some Scene {
        WindowGroup {
            RootView(authenticationService: authenticationService)
        }
        .modelContainer(for: Album.self)
    }
}

struct RootView: View {
    @ObservedObject var authenticationService: FirebaseAuthService
    
    var body: some View {
        Group {
            if authenticationService.authenticationState == .authenticated {
                AlbumTabView(authenticationService: authenticationService)
            } else {
                LoginViewWrapper(authenticationService: authenticationService)
            }
        }
    }
}

struct LoginViewWrapper: View {
    @ObservedObject var authenticationService: FirebaseAuthService
    @StateObject private var loginViewModel: LoginViewModel
    
    init(authenticationService: FirebaseAuthService) {
        self.authenticationService = authenticationService
        let userManager = UserFirestoreService()
        self._loginViewModel = StateObject(wrappedValue: LoginViewModel(
            authenticationService: authenticationService,
            userManager: userManager
        ))
    }
    
    var body: some View {
        LoginView(viewModel: loginViewModel)
    }
}
