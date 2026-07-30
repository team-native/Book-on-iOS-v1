import Foundation

public struct HomeData: Decodable, Sendable {
    public let banners: [HomeBanner]
    public let todayRecommendation: BookRecommendation?
    public let menus: [HomeMenu]
    public let externalServices: ExternalServices?
}

public struct ExternalServices: Decodable, Sendable {
    public let dls: ExternalServiceStatus?
}

public struct ExternalServiceStatus: Decodable, Sendable {
    public let status: String
    public let errorCode: Int?
    public let message: String?
    public let data: APIErrorDetail?

    public var isUnavailable: Bool {
        status == "UNAVAILABLE"
    }
}

public struct HomeBanner: Decodable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let contentType: String
    public let imageUrl: String?
    public let targetUrl: String?
}

public struct HomeMenu: Decodable, Sendable {
    public let code: String
    public let name: String
    public let path: String
}

public struct BookRecommendation: Decodable, Identifiable, Sendable {
    public let bookId: Int
    public let title: String
    public let author: String
    public let publisher: String
    public let category: String
    public let libraryNumber: String
    public let coverImageUrl: String?
    public let totalQuantity: Int
    public let availableQuantity: Int
    public let loanAvailable: Bool
    public let status: String?
    public let isbn: String?
    public let registeredAt: String
    public let reason: String?

    public var id: Int { bookId }
}

public struct NoticeListData: Decodable, Sendable {
    public let items: [Notice]
    public let pagination: Pagination
}

public struct Notice: Decodable, Identifiable, Sendable {
    public let noticeId: Int
    public let title: String
    public let summary: String
    public let createdAt: String

    public var id: Int { noticeId }
}

public struct TodayRecommendationsData: Decodable, Sendable {
    public let recommendedAt: String
    public let items: [BookRecommendation]
}

public struct Pagination: Decodable, Sendable {
    public let page: Int
    public let size: Int
    public let totalCount: Int
    public let totalPages: Int
    public let hasNext: Bool
}
