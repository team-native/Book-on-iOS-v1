import Foundation

public enum HealthCheckError: Error, Equatable {
    case invalidResponse
    case unsuccessfulStatusCode(Int)
}

public struct HealthCheckService: Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func check() async throws -> HealthCheckResponse {
        let url = APIConfiguration.baseURL.appendingPathComponent("life")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HealthCheckError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw HealthCheckError.unsuccessfulStatusCode(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(HealthCheckResponse.self, from: data)
    }
}
