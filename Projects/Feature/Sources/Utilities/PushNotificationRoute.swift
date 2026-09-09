import Foundation

/// FCM payload의 `type` 값에 따라 앱이 열어야 할 화면을 나타냅니다.
public enum PushNotificationRoute: Sendable {
    case loanHistory
    case notices

    public init?(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return nil }

        switch type {
        case "loan_due":
            self = .loanHistory
        case "notice":
            self = .notices
        default:
            // 서버가 새 알림 타입을 추가하더라도 앱이 예기치 않은 화면으로 이동하지 않게 합니다.
            return nil
        }
    }
}

public extension Notification.Name {
    /// App 타깃의 푸시 처리 결과를 Feature 화면 전환으로 전달합니다.
    static let bookOnPushNotificationRoute = Notification.Name("com.bookonios.push-notification-route")

    /// 알림 설정 화면에서 권한 승인을 요청하면 App 타깃이 APNs/FCM 등록을 시작합니다.
    static let bookOnRequestPushAuthorization = Notification.Name("com.bookonios.request-push-authorization")
}
