//
//  MusicBoxApp.swift
//  MusicBox
//
//  Created by Luca Lacerda on 20/09/25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth // << add this

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Configure Firebase only if not already configured
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    // --- Enforce "Remember me" policy right after Firebase is configured ---
    // If the user did NOT opt into auto-login, remove any restored session immediately.
    // Also allow skipping this sign-out for UI tests via a launch argument.
    let isUITestSkipSignOut = ProcessInfo.processInfo.arguments.contains("--ui-test-skip-signout")
    let autoLoginEnabled = UserDefaults.standard.bool(forKey: "autoLoginEnabled")

    if !isUITestSkipSignOut && !autoLoginEnabled {
      if Auth.auth().currentUser != nil {
        do {
          try Auth.auth().signOut()
          print("🔒 Signed out at launch because auto-login is disabled")
        } catch {
          print("⚠️ Failed to sign out at launch: \(error)")
        }
      } else {
        print("🔍 No existing Firebase user at launch")
      }
    } else {
      print("⚠️ Skipping sign-out at launch (UI test skip or auto-login enabled)")
    }
    // -----------------------------------------------------------------------

    return true
  }
}

@main
struct MusicBoxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authenticationService = FirebaseAuthService()

    init() {
        // 🔴 Skip login ONLY during UI tests
        if CommandLine.arguments.contains("UI_TEST_SKIP_LOGIN") {
            FirebaseAuthService.forceAuthenticatedForUITests = true
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(authenticationService: authenticationService)
        }
        .modelContainer(for: Album.self)
    }
}

struct RootView: View {
    @ObservedObject var authenticationService: FirebaseAuthService
    private let userManager = UserFirestoreService()
    
    @State private var currentUsername: String? = nil
    @State private var isLoadingUser: Bool = true
    
    var body: some View {
        Group {
            if authenticationService.authenticationState == .authenticated {
                if let userId = Auth.auth().currentUser?.uid, let username = currentUsername {
                    AlbumTabView(authenticationService: authenticationService,
                                 userId: userId,
                                 username: username)
                } else if isLoadingUser {
                    ProgressView("Loading user info...")
                        .onAppear {
                            loadUserInfo()
                        }
                } else {
                    Text("Failed to load user info")
                        .foregroundColor(.red)
                }
            } else {
                LoginViewWrapper(authenticationService: authenticationService)
            }
        }
    }
    
    private func loadUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoadingUser = false
            return
        }
        
        Task {
            do {
                currentUsername = try await userManager.fetchUsername(for: userId)
            } catch {
                print("❌ Failed to fetch username: \(error)")
                currentUsername = nil
            }
            isLoadingUser = false
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
