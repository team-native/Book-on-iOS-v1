import Foundation

public struct LoginRequest: Encodable, Sendable {
    public let loginId: String
    public let password: String

    public init(loginId: String, password: String) {
        self.loginId = loginId
        self.password = password
    }
}

public struct LoginResponse: Decodable, Sendable {
    public let userId: Int
    public let name: String
    public let email: String
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresIn: Int

    public init(
        userId: Int,
        name: String,
        email: String,
        accessToken: String,
        refreshToken: String,
        tokenType: String,
        expiresIn: Int
    ) {
        self.userId = userId
        self.name = name
        self.email = email
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
    }
}

public struct LoginService: Sendable {
    private let client: APIClient
    private let tokenStore: AuthTokenStore

    public init(
        client: APIClient = APIClient(),
        tokenStore: AuthTokenStore = AuthTokenStore()
    ) {
        self.client = client
        self.tokenStore = tokenStore
    }

    @discardableResult
    public func login(loginId: String, password: String) async throws -> LoginResponse {
        let endpoint = try APIEndpoint.json(
            path: "/auth/login",
            method: .post,
            body: LoginRequest(loginId: loginId, password: password)
        )
        let response = try await client.send(endpoint, as: LoginResponse.self)

        try tokenStore.save(
            accessToken: response.data.accessToken,
            refreshToken: response.data.refreshToken
        )

        return response.data
    }
}
