import SwiftUI
import Feature

@main
struct BookOnIOSV1App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var isSplashFinished = false
    @State private var isSigningUp = false
    @State private var isSignedIn = false

    var body: some View {
        ZStack {
            if !isSplashFinished {
                SplashView(onFinished: { isSplashFinished = true })
            } else if isSignedIn {
                AppShellView()
            } else {
                NavigationStack {
                    LoginView(
                        onLogin: { _, _ in isSignedIn = true },
                        onSignUp: { isSigningUp = true }
                    )
                        .navigationDestination(isPresented: $isSigningUp) {
                            SignUpFlowView(onFinished: {
                                isSigningUp = false
                                isSignedIn = true
                            })
                                .navigationBarTitleDisplayMode(.inline)
                        }
                }
            }
        }
    }
}
