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
        // 앱의 화면 배경은 라이트 팔레트로 고정되어 있으므로, 색을 따로 지정하지 않은
        // 텍스트도 기기 다크 모드에서 흰색으로 바뀌지 않게 기본 색을 명시한다.
        .foregroundColor(.black)
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
        .onReceive(NotificationCenter.default.publisher(for: .bookOnRequestPushAuthorization)) { _ in
            Task {
                _ = try? await PushNotificationCoordinator.shared.requestAuthorization()
                await PushNotificationCoordinator.shared.syncDeviceTokenIfPossible()
            }
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
