import Foundation

public struct RegisterRequest: Encodable, Sendable {
    public let email: String
    public let name: String
    public let department: String
    public let gender: String
    public let password: String
    public let passwordConfirm: String

    public init(
        email: String,
        name: String,
        department: String,
        gender: String,
        password: String,
        passwordConfirm: String
    ) {
        self.email = email
        self.name = name
        self.department = department
        self.gender = gender
        self.password = password
        self.passwordConfirm = passwordConfirm
    }
}

public struct RegisterResponse: Decodable, Sendable {
    public let sessionId: String
    public let expiresAt: String
    public let email: String

    public init(sessionId: String, expiresAt: String, email: String) {
        self.sessionId = sessionId
        self.expiresAt = expiresAt
        self.email = email
    }
}

public struct RegisterVerificationRequest: Encodable, Sendable {
    public let sessionId: String
    public let passcode: String

    public init(sessionId: String, passcode: String) {
        self.sessionId = sessionId
        self.passcode = passcode
    }
}

public struct RegisterVerificationResponse: Decodable, Sendable {
    public let userId: Int
    public let email: String
    public let name: String

    public init(userId: Int, email: String, name: String) {
        self.userId = userId
        self.email = email
        self.name = name
    }
}

public struct RegisterService: Sendable {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    @discardableResult
    public func register(_ request: RegisterRequest) async throws -> RegisterResponse {
        let endpoint = try APIEndpoint.json(
            path: "/auth/register",
            method: .post,
            body: request
        )
        let response = try await client.send(endpoint, as: RegisterResponse.self)
        return response.data
    }

    @discardableResult
    public func verify(_ request: RegisterVerificationRequest) async throws -> RegisterVerificationResponse {
        let endpoint = try APIEndpoint.json(
            path: "/auth/register/verify",
            method: .post,
            body: request
        )
        let response = try await client.send(endpoint, as: RegisterVerificationResponse.self)
        return response.data
    }
}
