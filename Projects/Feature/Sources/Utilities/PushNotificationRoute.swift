import Foundation

/// FCM payload의 `type` 값에 따라 앱이 열어야 할 화면을 나타냅니다.
public enum PushNotificationRoute: Sendable {
    case loanHistory
    case notices
    case newArrivals
    case bookDetail(Int)

    public init?(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return nil }
        self.init(type: type, bookId: Self.bookID(from: userInfo["bookId"]))
    }

    public init?(type: String, deepLink: String? = nil) {
        self.init(type: type, bookId: Self.bookID(from: deepLink))
    }

    private init?(type: String, bookId: Int?) {
        switch type {
        case "loan_due":
            self = .loanHistory
        case "notice":
            self = .notices
        case "new_book":
            if let bookId {
                self = .bookDetail(bookId)
            } else {
                // 오래된 알림처럼 도서 ID가 없으면 신간 목록으로 안전하게 연결합니다.
                self = .newArrivals
            }
        default:
            // 서버가 새 알림 타입을 추가하더라도 앱이 예기치 않은 화면으로 이동하지 않게 합니다.
            return nil
        }
    }

    private static func bookID(from value: Any?) -> Int? {
        if let id = value as? Int, id > 0 {
            return id
        }
        if let value = value as? String, let id = Int(value), id > 0 {
            return id
        }
        return nil
    }

    private static func bookID(from deepLink: String?) -> Int? {
        guard let deepLink,
              let path = URLComponents(string: deepLink)?.path,
              path.hasPrefix("/books/")
        else { return nil }

        let components = path.split(separator: "/")
        guard components.count == 2, components[0] == "books",
              let id = Int(components[1]), id > 0
        else { return nil }
        return id
    }
}

public extension Notification.Name {
    /// App 타깃의 푸시 처리 결과를 Feature 화면 전환으로 전달합니다.
    static let bookOnPushNotificationRoute = Notification.Name("com.bookonios.push-notification-route")

    /// 알림 설정 화면에서 권한 승인을 요청하면 App 타깃이 APNs/FCM 등록을 시작합니다.
    static let bookOnRequestPushAuthorization = Notification.Name("com.bookonios.request-push-authorization")
}
