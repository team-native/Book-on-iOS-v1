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
}
