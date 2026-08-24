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
                        onLogin: { _, _ in
                            authenticationState = .signedIn
                            Task { await PushNotificationCoordinator.shared.syncDeviceTokenIfPossible() }
                        },
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
        .onChange(of: isSplashFinished) { _ in
            activatePushRouteDeliveryIfReady()
        }
        .onChange(of: authenticationState) { _ in
            activatePushRouteDeliveryIfReady()
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
            if authenticationState == .signedIn {
                Task { await PushNotificationCoordinator.shared.syncDeviceTokenIfPossible() }
            }
        } catch {
            authenticationState = .signedOut
        }
    }

    private func signOut() {
        isSigningUp = false
        isResettingPassword = false
        authenticationState = .signedOut
        Task {
            await PushNotificationCoordinator.shared.unregisterDeviceTokenIfPossible()
            try? await loginService.logout()
        }
    }

    private func activatePushRouteDeliveryIfReady() {
        guard isSplashFinished, authenticationState == .signedIn else { return }

        // AppShell이 화면 계층에 추가된 뒤 이벤트를 보내도록 다음 런 루프에서 전달합니다.
        DispatchQueue.main.async {
            PushNotificationCoordinator.shared.activateRouteDelivery()
        }
    }
}
