import Foundation

public struct ReaderRanking: Decodable, Sendable, Identifiable {
    public let rank: Int
    public let userId: Int
    public let name: String
    public let department: String
    public let profileImageUrl: String?
    public let loanCount: Int
    public var id: Int { userId }
}

public struct ReaderRankingData: Decodable, Sendable {
    public let year: Int
    public let resetPolicy: String
    public let items: [ReaderRanking]
}

public struct RankingService: Sendable {
    private let client: APIClient
    public init(client: APIClient = APIClient()) { self.client = client }

    public func fetchReaders(year: Int, limit: Int = 10) async throws -> ReaderRankingData {
        let query = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "limit", value: String(limit)),
        ]
        return try await client.send(
            APIEndpoint(path: "/rankings/readers", queryItems: query),
            as: ReaderRankingData.self
        ).data
    }
}
