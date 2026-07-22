import Foundation

public struct MarathonCourse: Decodable, Sendable {
    public let courseName: String?
    public let completeDistance: String?
}

public struct MarathonSummary: Decodable, Sendable, Identifiable {
    public let readingMarathonKey: String
    public let contestName: String
    public let myTotalPage: Int
    public let deadLineDays: Int?
    public let course: MarathonCourse?

    public var id: String { readingMarathonKey }
}

public struct MarathonData: Decodable, Sendable {
    public let read365Id: String
    public let memberKey: String
    public let schoolKey: String
    public let activeCount: Int
    public let marathons: [MarathonSummary]
}

public struct Read365MyProfile: Decodable, Sendable {
    public let name: String
    public let memGrade: String?
    public let memClass: String?
    public let memNo: String?
    public let schName: String?
    public let continuousLoginDays: Int?
}

public struct Read365MyInfo: Decodable, Sendable {
    public let read365Id: String
    public let memberKey: String
    public let schoolKey: String
    public let profile: Read365MyProfile
}

public struct MarathonService: Sendable {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    public func fetchMarathon() async throws -> MarathonData {
        try await client.send(
            APIEndpoint(path: "/marathon", requiresAuthorization: true),
            as: MarathonData.self
        ).data
    }

    public func fetchMyInfo() async throws -> Read365MyInfo {
        try await client.send(
            APIEndpoint(path: "/marathon/read365/myinfo", requiresAuthorization: true),
            as: Read365MyInfo.self
        ).data
    }
}
