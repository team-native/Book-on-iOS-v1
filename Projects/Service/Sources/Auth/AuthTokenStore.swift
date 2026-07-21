import Foundation
import Security

public enum AuthToken: String, CaseIterable, Sendable {
    case accessToken
    case refreshToken
}

public enum AuthTokenStoreError: Error, Equatable {
    case invalidData
    case keychain(OSStatus)
}

extension AuthTokenStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidData:
            return "저장된 인증 토큰을 읽을 수 없습니다."
        case let .keychain(status):
            let message = SecCopyErrorMessageString(status, nil) as String?
            return message ?? "Keychain 요청에 실패했습니다. (\(status))"
        }
    }
}

public struct AuthTokenStore: Sendable {
    private let service: String

    public init(service: String = "com.bookonios.auth-tokens") {
        self.service = service
    }

    public func save(_ value: String, for token: AuthToken) throws {
        guard let data = value.data(using: .utf8) else {
            throw AuthTokenStoreError.invalidData
        }

        let query = baseQuery(for: token)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw AuthTokenStoreError.keychain(updateStatus)
        }

        var addQuery = query
        attributes.forEach { addQuery[$0.key] = $0.value }

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw AuthTokenStoreError.keychain(addStatus)
        }
    }

    public func read(_ token: AuthToken) throws -> String? {
        var query = baseQuery(for: token)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw AuthTokenStoreError.keychain(status)
        }

        guard
            let data = result as? Data,
            let value = String(data: data, encoding: .utf8)
        else {
            throw AuthTokenStoreError.invalidData
        }

        return value
    }

    public func delete(_ token: AuthToken) throws {
        let status = SecItemDelete(baseQuery(for: token) as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AuthTokenStoreError.keychain(status)
        }
    }

    public func deleteAll() throws {
        for token in AuthToken.allCases {
            try delete(token)
        }
    }

    public var accessToken: String? {
        get throws { try read(.accessToken) }
    }

    public var refreshToken: String? {
        get throws { try read(.refreshToken) }
    }

    public func save(accessToken: String, refreshToken: String) throws {
        try save(accessToken, for: .accessToken)

        do {
            try save(refreshToken, for: .refreshToken)
        } catch {
            try? delete(.accessToken)
            throw error
        }
    }

    private func baseQuery(for token: AuthToken) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: token.rawValue,
        ]
    }
}
