import Foundation

public struct NotificationHistoryData: Decodable, Sendable {
    public let notifications: [NotificationHistoryItem]
    public let pagination: Pagination
}

public struct NotificationHistoryItem: Decodable, Identifiable, Sendable {
    public let id: Int
    public let type: String
    public let title: String
    public let body: String
    public let isRead: Bool
    public let createdAt: String
    public let deepLink: String?

    public init(
        id: Int,
        type: String,
        title: String,
        body: String,
        isRead: Bool,
        createdAt: String,
        deepLink: String?
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.isRead = isRead
        self.createdAt = createdAt
        self.deepLink = deepLink
    }
}

public struct NotificationHistoryService: Sendable {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    public func fetchNotifications(page: Int = 1, size: Int = 30) async throws -> NotificationHistoryData {
        let endpoint = APIEndpoint(
            path: "/me/notifications",
            queryItems: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size)),
            ],
            requiresAuthorization: true
        )
        return try await client.send(endpoint, as: NotificationHistoryData.self).data
    }

    public func markRead(notificationId: Int) async throws {
        let endpoint = APIEndpoint(
            path: "/me/notifications/\(notificationId)/read",
            method: .patch,
            requiresAuthorization: true
        )
        _ = try await client.send(endpoint, as: NotificationReadData.self)
    }
}

private struct NotificationReadData: Decodable {
    let id: Int
    let isRead: Bool
}
