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

    var body: some View {
        ZStack {
            if !isSplashFinished {
                SplashView(onFinished: { isSplashFinished = true })
            } else {
                NavigationStack {
                    LoginView(onSignUp: { isSigningUp = true })
                        .navigationDestination(isPresented: $isSigningUp) {
                            SignUpFlowView(onFinished: { isSigningUp = false })
                                .navigationBarTitleDisplayMode(.inline)
                        }
                }
            }
        }
    }
}
