import Foundation

public struct MeUser: Decodable, Sendable {
    public let userId: Int
    public let email: String
    public let name: String
    public let department: String
    public let gender: String
}

public struct MeLoanSummary: Decodable, Sendable {
    public let currentLoanCount: Int
    public let overdueCount: Int
    public let nearestDueDate: String?
    public let nearestDueDday: Int?
}

public struct MeCurrentLoan: Decodable, Sendable, Identifiable {
    public let loanId: Int
    public let bookId: Int
    public let title: String
    public let dueDate: String
    public let dDay: Int
    public let extensionAvailable: Bool
    public var id: Int { loanId }
}

public struct NotificationSettings: Codable, Sendable {
    public let dueDateReminder: Bool
    public let newBookReminder: Bool

    public init(dueDateReminder: Bool, newBookReminder: Bool) {
        self.dueDateReminder = dueDateReminder
        self.newBookReminder = newBookReminder
    }
}

public struct MeData: Decodable, Sendable {
    public let user: MeUser
    public let loanSummary: MeLoanSummary
    public let currentLoans: [MeCurrentLoan]
    public let notificationSettings: NotificationSettings
}

public struct MeService: Sendable {
    private let client: APIClient
    public init(client: APIClient = APIClient()) { self.client = client }

    public func fetchMe() async throws -> MeData {
        try await client.send(
            APIEndpoint(path: "/me", requiresAuthorization: true),
            as: MeData.self
        ).data
    }

    public func updateNotificationSettings(_ settings: NotificationSettings) async throws -> NotificationSettings {
        let endpoint = try APIEndpoint.json(
            path: "/me/notification-settings",
            method: .patch,
            body: settings,
            requiresAuthorization: true
        )
        return try await client.send(endpoint, as: NotificationSettings.self).data
    }
}
