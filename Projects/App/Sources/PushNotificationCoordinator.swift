import Foundation
import UIKit
import UserNotifications

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

/// Owns the Apple Push Notification service (APNs) registration lifecycle.
///
/// Firebase Messaging is deliberately optional for now: adding Firebase to the
/// Tuist package and `GoogleService-Info.plist` will activate the FCM bridge
/// without changing any call sites in the app.
final class PushNotificationCoordinator: NSObject {
    static let shared = PushNotificationCoordinator()

    /// Posted when the user opens a notification. A later app-shell router can
    /// observe this and navigate to a book, loan, or notification detail.
    static let didOpenNotification = Notification.Name("PushNotificationCoordinator.didOpenNotification")

    private override init() {
        super.init()
    }

    /// Configures Firebase only when the production Firebase plist is present.
    /// This lets local builds work before the project-specific file is supplied.
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

    /// Call from an explicit user-facing notification preference flow, not at
    /// launch. This prevents an unexpected permission prompt on first run.
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

        // TODO: Send this token through the backend's authenticated device-token
        // registration API once its request/response contract is finalized.
        // Never send an APNs token to the backend when FCM is the delivery layer.
    }
}
#endif
