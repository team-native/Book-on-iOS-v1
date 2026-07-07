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

    var body: some View {
        if isSplashFinished {
            LoginView()
        } else {
            SplashView(onFinished: { isSplashFinished = true })
        }
    }
}
