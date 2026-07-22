import Foundation

public struct PasswordResetEmailRequest: Encodable, Sendable {
    public let email: String

    public init(email: String) {
        self.email = email
    }
}

public struct PasswordResetEmailResponse: Decodable, Sendable {
    public let email: String
    public let expiresIn: Int

    public init(email: String, expiresIn: Int) {
        self.email = email
        self.expiresIn = expiresIn
    }
}

public struct PasswordResetRequest: Encodable, Sendable {
    public let email: String
    public let verificationCode: String
    public let newPassword: String
    public let newPasswordConfirm: String

    public init(
        email: String,
        verificationCode: String,
        newPassword: String,
        newPasswordConfirm: String
    ) {
        self.email = email
        self.verificationCode = verificationCode
        self.newPassword = newPassword
        self.newPasswordConfirm = newPasswordConfirm
    }
}

public struct PasswordResetResponse: Decodable, Sendable {
    public let email: String

    public init(email: String) {
        self.email = email
    }
}

public struct PasswordResetService: Sendable {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    @discardableResult
    public func sendVerificationEmail(to email: String) async throws -> PasswordResetEmailResponse {
        let endpoint = try APIEndpoint.json(
            path: "/auth/password-reset/email",
            method: .post,
            body: PasswordResetEmailRequest(email: email)
        )
        let response = try await client.send(endpoint, as: PasswordResetEmailResponse.self)
        return response.data
    }

    @discardableResult
    public func resetPassword(_ request: PasswordResetRequest) async throws -> PasswordResetResponse {
        let endpoint = try APIEndpoint.json(
            path: "/auth/password-reset",
            method: .patch,
            body: request
        )
        let response = try await client.send(endpoint, as: PasswordResetResponse.self)
        return response.data
    }
}
