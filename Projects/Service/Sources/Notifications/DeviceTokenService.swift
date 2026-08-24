import Foundation

public enum DevicePlatform: String, Encodable, Sendable {
    case iOS = "ios"
}

public struct DeviceTokenRequest: Encodable, Sendable {
    public let token: String
    public let platform: DevicePlatform

    public init(token: String, platform: DevicePlatform = .iOS) {
        self.token = token
        self.platform = platform
    }
}

private struct DeviceTokenDeletionRequest: Encodable {
    let token: String
}

private struct DeviceTokenRegistrationResponse: Decodable {
    let registered: Bool
}

private struct DeviceTokenDeletionResponse: Decodable {
    let unregistered: Bool
}

/// 로그인한 기기의 푸시 토큰을 서버 알림 발송 대상에 등록합니다.
public struct DeviceTokenService: Sendable {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    public func register(token: String) async throws {
        let endpoint = try APIEndpoint.json(
            path: "/me/fcm-token",
            method: .post,
            body: DeviceTokenRequest(token: token),
            requiresAuthorization: true
        )
        _ = try await client.send(endpoint, as: DeviceTokenRegistrationResponse.self)
    }

    public func unregister(token: String) async throws {
        let endpoint = try APIEndpoint.json(
            path: "/me/fcm-token",
            method: .delete,
            body: DeviceTokenDeletionRequest(token: token),
            requiresAuthorization: true
        )
        _ = try await client.send(endpoint, as: DeviceTokenDeletionResponse.self)
    }
}
