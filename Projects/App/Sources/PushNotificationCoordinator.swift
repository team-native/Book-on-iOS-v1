import Foundation
import UIKit
import UserNotifications

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

/// Apple Push Notification service(APNs) 등록 과정을 관리합니다.
///
/// 현재 Firebase Messaging은 선택적으로 연결됩니다. Tuist 패키지와
/// `GoogleService-Info.plist`를 추가하면 앱의 호출부를 바꾸지 않아도 FCM 연동이 활성화됩니다.
final class PushNotificationCoordinator: NSObject {
    static let shared = PushNotificationCoordinator()

    /// 사용자가 알림을 열었을 때 전달됩니다. 앱 셸 라우터가 이를 구독해
    /// 도서, 대출 또는 알림 상세 화면으로 이동할 수 있습니다.
    static let didOpenNotification = Notification.Name("PushNotificationCoordinator.didOpenNotification")

    private override init() {
        super.init()
    }

    /// 실제 Firebase 설정 파일이 있을 때만 Firebase를 초기화합니다.
    /// 프로젝트별 설정 파일이 없어도 로컬 빌드가 가능하도록 하는 처리입니다.
    @discardableResult
    func configureFirebaseIfAvailable() -> Bool {
        #if canImport(FirebaseCore) && canImport(FirebaseMessaging)
        guard FirebaseApp.app() == nil else {
            Messaging.messaging().delegate = self
            return true
        }

        guard let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: plistPath)
        else {
            #if DEBUG
            print("Firebase is not configured: GoogleService-Info.plist is missing.")
            #endif
            return false
        }

        FirebaseApp.configure(options: options)
        Messaging.messaging().delegate = self
        return true
        #else
        return false
        #endif
    }

    /// 앱 실행 시점이 아닌 사용자가 알림 설정을 선택한 흐름에서 호출합니다.
    /// 첫 실행에 예기치 않은 권한 요청이 표시되는 것을 막습니다.
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        guard granted else { return false }

        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
        return true
    }

    func registerForRemoteNotificationsIfAuthorized() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func didRegisterForRemoteNotifications(deviceToken: Data) {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().apnsToken = deviceToken
        #endif
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        #if DEBUG
        print("APNs registration failed: \(error.localizedDescription)")
        #endif
    }
}

extension PushNotificationCoordinator: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        NotificationCenter.default.post(
            name: Self.didOpenNotification,
            object: nil,
            userInfo: response.notification.request.content.userInfo
        )
    }
}

#if canImport(FirebaseMessaging)
extension PushNotificationCoordinator: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken, !fcmToken.isEmpty else { return }

        // TODO: 백엔드의 기기 토큰 등록 API 명세가 확정되면, 로그인한 사용자의
        // FCM 토큰을 해당 API로 전송합니다.
        // FCM을 발송 경로로 사용할 때는 APNs 토큰이 아닌 FCM 토큰만 백엔드에 전송합니다.
    }
}
#endif
