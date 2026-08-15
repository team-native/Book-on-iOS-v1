import Foundation

public struct Read365Profile: Decodable, Sendable {
    public let memberKey: String
    public let schKey: String
    public let id: String?
    public let name: String?
}

public struct Read365SessionRequest: Encodable, Sendable {
    public let cookieHeader: String
    public let read365Id: String?
    public let sessionExpiresAt: String?

    public init(
        cookieHeader: String,
        read365Id: String? = nil,
        sessionExpiresAt: String? = nil
    ) {
        self.cookieHeader = cookieHeader
        self.read365Id = read365Id
        self.sessionExpiresAt = sessionExpiresAt
    }
}

public struct Read365SessionResponse: Decodable, Sendable {
    public let read365Id: String
    public let sessionExpiresAt: String
    public let profile: Read365Profile
}

public struct Read365Service: Sendable {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    @discardableResult
    public func registerSession(
        cookieHeader: String
    ) async throws -> Read365SessionResponse {
        let endpoint = try APIEndpoint.json(
            path: "/auth/read365/session",
            method: .post,
            body: Read365SessionRequest(
                cookieHeader: cookieHeader
            ),
            requiresAuthorization: true
        )
        return try await client.send(endpoint, as: Read365SessionResponse.self).data
    }

    @discardableResult
    public func extendSession() async throws -> Read365SessionResponse {
        try await client.send(
            APIEndpoint(
                path: "/auth/read365/session/extend",
                method: .post,
                requiresAuthorization: true
            ),
            as: Read365SessionResponse.self
        ).data
    }
}
