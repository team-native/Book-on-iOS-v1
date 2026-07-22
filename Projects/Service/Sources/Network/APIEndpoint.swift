import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

public struct APIEndpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]
    public let headers: [String: String]
    public let body: Data?
    public let requiresAuthorization: Bool
    public let usesAuthorizationIfAvailable: Bool

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil,
        requiresAuthorization: Bool = false,
        usesAuthorizationIfAvailable: Bool = false
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.requiresAuthorization = requiresAuthorization
        self.usesAuthorizationIfAvailable = usesAuthorizationIfAvailable
    }

    public static func json<Body: Encodable>(
        path: String,
        method: HTTPMethod,
        body: Body,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        requiresAuthorization: Bool = false,
        usesAuthorizationIfAvailable: Bool = false,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> APIEndpoint {
        try APIEndpoint(
            path: path,
            method: method,
            queryItems: queryItems,
            headers: headers,
            body: encoder.encode(body),
            requiresAuthorization: requiresAuthorization,
            usesAuthorizationIfAvailable: usesAuthorizationIfAvailable
        )
    }
}
