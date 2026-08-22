import SwiftUI
import Feature
import Service

@main
struct BookOnIOSV1App: App {
    @UIApplicationDelegateAdaptor(BookOnAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    private enum AuthenticationState {
        case checking
        case signedOut
        case signedIn
    }

    @State private var isSplashFinished = false
    @State private var isSigningUp = false
    @State private var isResettingPassword = false
    @State private var authenticationState: AuthenticationState = .checking
    @State private var showsSessionExpiredAlert = false

    private let tokenStore = AuthTokenStore()
    private let loginService = LoginService()

    var body: some View {
        ZStack {
            if !isSplashFinished {
                SplashView(onFinished: { isSplashFinished = true })
            } else if authenticationState == .signedIn {
                AppShellView(onLogout: signOut)
            } else if authenticationState == .signedOut {
                NavigationStack {
                    LoginView(
                        onLogin: { _, _ in authenticationState = .signedIn },
                        onForgotPassword: { isResettingPassword = true },
                        onSignUp: { isSigningUp = true }
                        )
                        .navigationDestination(isPresented: $isResettingPassword) {
                            PasswordResetView(
                                onBack: { isResettingPassword = false },
                                onCompleted: { isResettingPassword = false }
                            )
                        }
                        .navigationDestination(isPresented: $isSigningUp) {
                            SignUpFlowView(onFinished: {
                                isSigningUp = false
                            })
                                .navigationBarTitleDisplayMode(.inline)
                        }
                }
            } else {
                Color.clear
            }
        }
        .task {
            restoreAuthenticationState()
        }
        .onReceive(NotificationCenter.default.publisher(for: AuthSessionEvent.didExpire)) { _ in
            authenticationState = .signedOut
            isSigningUp = false
            isResettingPassword = false
            showsSessionExpiredAlert = true
        }
        .alert("로그인 세션 만료", isPresented: $showsSessionExpiredAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("다시 로그인해주세요.")
        }
    }

    private func restoreAuthenticationState() {
        do {
            let accessToken = try tokenStore.accessToken
            authenticationState = accessToken?.isEmpty == false ? .signedIn : .signedOut
        } catch {
            authenticationState = .signedOut
        }
    }

    private func signOut() {
        isSigningUp = false
        isResettingPassword = false
        authenticationState = .signedOut
        Task {
            try? await loginService.logout()
        }
    }
}
