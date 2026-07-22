import Foundation

public struct BookSummary: Decodable, Identifiable, Sendable {
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

    public var id: Int { bookId }
}

public struct BookListData: Decodable, Sendable {
    public let items: [BookSummary]
    public let pagination: Pagination
}

public struct BookCategoryListData: Decodable, Sendable {
    public let items: [BookCategory]
}

public struct BookCategory: Decodable, Identifiable, Sendable {
    public let categoryId: Int
    public let code: String
    public let name: String
    public let bookCount: Int

    public var id: Int { categoryId }
}

public struct BookDetail: Decodable, Identifiable, Sendable {
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
    public let description: String?
    public let favorite: Bool
    public let locationName: String?
    public let returnPlanDate: String?

    public var id: Int { bookId }
}

public struct FavoriteStatus: Decodable, Sendable {
    public let bookId: Int
    public let favorite: Bool
}

public struct FavoriteBookListData: Decodable, Sendable {
    public let items: [FavoriteBook]
    public let pagination: Pagination
}

public struct FavoriteBook: Decodable, Identifiable, Sendable {
    public let bookId: Int
    public let title: String
    public let author: String
    public let libraryNumber: String
    public let availableQuantity: Int
    public let loanAvailable: Bool
    public let favoritedAt: String

    public var id: Int { bookId }
}
