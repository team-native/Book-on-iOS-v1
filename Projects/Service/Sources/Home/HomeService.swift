import Foundation

public struct HomeService: Sendable {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    public func fetchHome(limit: Int = 5) async throws -> HomeData {
        let endpoint = APIEndpoint(
            path: "/home",
            queryItems: [URLQueryItem(name: "limit", value: String(limit))]
        )
        return try await client.send(endpoint, as: HomeData.self).data
    }

    public func fetchNotices(page: Int = 1, size: Int = 10) async throws -> NoticeListData {
        let endpoint = APIEndpoint(
            path: "/notices",
            queryItems: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size)),
            ]
        )
        return try await client.send(endpoint, as: NoticeListData.self).data
    }

    public func fetchTodayRecommendations() async throws -> TodayRecommendationsData {
        let endpoint = APIEndpoint(path: "/books/recommendations/today")
        return try await client.send(endpoint, as: TodayRecommendationsData.self).data
    }
}
