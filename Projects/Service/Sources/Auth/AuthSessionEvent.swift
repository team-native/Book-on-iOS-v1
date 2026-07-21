import Foundation

public enum AuthSessionEvent {
    public static let didExpire = Notification.Name("com.bookonios.auth.session-expired")
}
