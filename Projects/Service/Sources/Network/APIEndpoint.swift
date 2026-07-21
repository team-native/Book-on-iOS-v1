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

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }

    public static func json<Body: Encodable>(
        path: String,
        method: HTTPMethod,
        body: Body,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> APIEndpoint {
        try APIEndpoint(
            path: path,
            method: method,
            queryItems: queryItems,
            headers: headers,
            body: encoder.encode(body)
        )
    }
}
