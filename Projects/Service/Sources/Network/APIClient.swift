import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case server(statusCode: Int, errorCode: Int?, message: String?)
    case decoding(Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "요청 URL을 만들 수 없습니다."
        case .invalidResponse:
            return "서버 응답을 확인할 수 없습니다."
        case let .server(_, _, message):
            return message ?? "서버 요청에 실패했습니다."
        case let .decoding(error):
            return "서버 응답을 처리하지 못했습니다: \(error.localizedDescription)"
        }
    }
}

public struct APIClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        baseURL: URL = APIConfiguration.baseURL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    public func send<ResponseData: Decodable>(
        _ endpoint: APIEndpoint,
        as type: ResponseData.Type = ResponseData.self
    ) async throws -> APIResponse<ResponseData> {
        let request = try makeURLRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.server(
                statusCode: httpResponse.statusCode,
                errorCode: errorResponse?.errorCode,
                message: errorResponse?.message
            )
        }

        do {
            let response = try decoder.decode(APIResponse<ResponseData>.self, from: data)

            guard response.errorCode == 0 else {
                throw NetworkError.server(
                    statusCode: httpResponse.statusCode,
                    errorCode: response.errorCode,
                    message: response.message
                )
            }

            return response
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    private func makeURLRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        let path = endpoint.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpointURL = baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        endpoint.headers.forEach { field, value in
            request.setValue(value, forHTTPHeaderField: field)
        }

        return request
    }
}
