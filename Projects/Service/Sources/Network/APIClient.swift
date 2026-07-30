import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case missingAccessToken
    case sessionExpired(message: String?)
    case server(statusCode: Int, errorCode: Int?, message: String?, detail: APIErrorDetail?)
    case decoding(Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "요청 URL을 만들 수 없습니다."
        case .invalidResponse:
            return "서버 응답을 확인할 수 없습니다."
        case .missingAccessToken:
            return "로그인이 필요한 기능입니다."
        case let .sessionExpired(message):
            return message ?? "로그인 세션이 만료되었습니다. 다시 로그인해주세요."
        case let .server(_, errorCode, message, _):
            switch errorCode {
            case 5021:
                return "학교 도서관 서버에 연결할 수 없습니다."
            case 5022:
                return "학교 도서관 응답 시간이 초과되었습니다."
            case 5023:
                return "학교 도서관 서버가 일시적으로 응답하지 않습니다."
            case 5024:
                return "학교 도서관 응답을 처리할 수 없습니다."
            case 5025:
                return "학교 도서관 자료를 조회하지 못했습니다."
            default:
                return message ?? "서버 요청에 실패했습니다."
            }
        case let .decoding(error):
            return "서버 응답을 처리하지 못했습니다: \(error.localizedDescription)"
        }
    }
}

public struct APIClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenStore: AuthTokenStore

    public init(
        baseURL: URL = APIConfiguration.baseURL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        tokenStore: AuthTokenStore = AuthTokenStore()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.tokenStore = tokenStore
    }

    public func send<ResponseData: Decodable>(
        _ endpoint: APIEndpoint,
        as type: ResponseData.Type = ResponseData.self
    ) async throws -> APIResponse<ResponseData> {
        try await send(endpoint, as: type, allowsTokenRefresh: true)
    }

    private func send<ResponseData: Decodable>(
        _ endpoint: APIEndpoint,
        as type: ResponseData.Type,
        allowsTokenRefresh: Bool
    ) async throws -> APIResponse<ResponseData> {
        let request = try makeURLRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)

            if endpoint.requiresAuthorization,
               httpResponse.statusCode == 401,
               errorResponse?.errorCode == nil || errorResponse?.errorCode == 4010 {
                if allowsTokenRefresh, try await refreshTokens() {
                    return try await send(endpoint, as: type, allowsTokenRefresh: false)
                }

                try? tokenStore.deleteAll()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: AuthSessionEvent.didExpire, object: nil)
                }
                throw NetworkError.sessionExpired(message: errorResponse?.message)
            }

            throw NetworkError.server(
                statusCode: httpResponse.statusCode,
                errorCode: errorResponse?.errorCode,
                message: errorResponse?.message,
                detail: errorResponse?.data
            )
        }

        do {
            let response = try decoder.decode(APIResponse<ResponseData>.self, from: data)

            guard response.errorCode == 0 else {
                throw NetworkError.server(
                    statusCode: httpResponse.statusCode,
                    errorCode: response.errorCode,
                    message: response.message,
                    detail: nil
                )
            }

            return response
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    private func refreshTokens() async throws -> Bool {
        guard let refreshToken = try tokenStore.refreshToken, !refreshToken.isEmpty else {
            return false
        }

        let endpoint = try APIEndpoint.json(
            path: "/auth/refresh",
            method: .post,
            body: TokenRefreshRequest(refreshToken: refreshToken)
        )
        let request = try makeURLRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode,
              let refreshed = try? decoder.decode(APIResponse<TokenRefreshData>.self, from: data),
              refreshed.errorCode == 0
        else {
            return false
        }

        try tokenStore.save(
            accessToken: refreshed.data.accessToken,
            refreshToken: refreshed.data.refreshToken
        )
        return true
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

        if endpoint.requiresAuthorization {
            guard let accessToken = try tokenStore.accessToken, !accessToken.isEmpty else {
                throw NetworkError.missingAccessToken
            }
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else if endpoint.usesAuthorizationIfAvailable,
                  let accessToken = try tokenStore.accessToken,
                  !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}

private struct TokenRefreshRequest: Encodable {
    let refreshToken: String
}

private struct TokenRefreshData: Decodable {
    let accessToken: String
    let refreshToken: String
}
