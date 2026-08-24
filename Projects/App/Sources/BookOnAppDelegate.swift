import UIKit

final class BookOnAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        PushNotificationCoordinator.shared.configureFirebaseIfAvailable()
        PushNotificationCoordinator.shared.registerForRemoteNotificationsIfAuthorized()

        // 앱이 종료된 상태에서 푸시를 탭해 실행된 경우에도 동일한 라우팅 흐름을 사용합니다.
        if let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            PushNotificationCoordinator.shared.handleNotification(userInfo: userInfo)
        }
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationCoordinator.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        PushNotificationCoordinator.shared.didFailToRegisterForRemoteNotifications(error: error)
    }
}
