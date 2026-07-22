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
}

public struct Read365LoginResponse: Decodable, Sendable {
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
}
