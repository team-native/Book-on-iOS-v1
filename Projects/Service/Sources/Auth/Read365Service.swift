import Foundation

public struct Read365LoginRequest: Encodable, Sendable {
    public let id: String
    public let password: String

    public init(id: String, password: String) {
        self.id = id
        self.password = password
    }
}

public struct Read365Profile: Decodable, Sendable {
    public let memberKey: String
    public let schKey: String
    public let id: String?
    public let name: String?
}

public struct Read365LoginResponse: Decodable, Sendable {
    public let read365Id: String
    public let sessionExpiresAt: String
    public let profile: Read365Profile
}

public struct Read365SessionRequest: Encodable, Sendable {
    public let cookieHeader: String
    public let read365Id: String
    public let sessionExpiresAt: String

    public init(cookieHeader: String, read365Id: String, sessionExpiresAt: String) {
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
    public func login(id: String, password: String) async throws -> Read365LoginResponse {
        let endpoint = try APIEndpoint.json(
            path: "/auth/read365/login",
            method: .post,
            body: Read365LoginRequest(id: id, password: password),
            requiresAuthorization: true
        )
        return try await client.send(endpoint, as: Read365LoginResponse.self).data
    }

    @discardableResult
    public func registerSession(
        cookieHeader: String,
        read365Id: String,
        sessionExpiresAt: String
    ) async throws -> Read365SessionResponse {
        let endpoint = try APIEndpoint.json(
            path: "/auth/read365/session",
            method: .post,
            body: Read365SessionRequest(
                cookieHeader: cookieHeader,
                read365Id: read365Id,
                sessionExpiresAt: sessionExpiresAt
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
