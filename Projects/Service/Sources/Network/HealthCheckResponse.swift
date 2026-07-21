import Foundation

public struct HealthCheckResponse: Decodable, Equatable, Sendable {
    public let status: String

    public init(status: String) {
        self.status = status
    }
}
