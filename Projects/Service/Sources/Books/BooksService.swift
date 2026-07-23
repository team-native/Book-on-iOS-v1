import Foundation

public struct BooksService: Sendable {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    public func fetchBooks(sort: String, category: String? = nil, page: Int = 1, size: Int = 20) async throws -> BookListData {
        var query = [
            URLQueryItem(name: "sort", value: sort),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size)),
        ]
        if let category, !category.isEmpty { query.append(URLQueryItem(name: "category", value: category)) }
        return try await client.send(APIEndpoint(path: "/books", queryItems: query), as: BookListData.self).data
    }

    public func searchBooks(
        keyword: String? = nil,
        libraryNumber: String? = nil,
        page: Int = 1,
        size: Int = 20
    ) async throws -> BookListData {
        var query = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size)),
        ]
        if let keyword, !keyword.isEmpty {
            query.append(URLQueryItem(name: "keyword", value: keyword))
        }
        if let libraryNumber, !libraryNumber.isEmpty {
            query.append(URLQueryItem(name: "libraryNumber", value: libraryNumber))
        }
        return try await client.send(APIEndpoint(path: "/books/search", queryItems: query), as: BookListData.self).data
    }

    public func fetchCategories() async throws -> [BookCategory] {
        try await client.send(APIEndpoint(path: "/books/categories"), as: BookCategoryListData.self).data.items
    }

    public func fetchNewBooks(page: Int = 1, size: Int = 20) async throws -> BookListData {
        let query = [URLQueryItem(name: "page", value: String(page)), URLQueryItem(name: "size", value: String(size))]
        return try await client.send(APIEndpoint(path: "/books/new", queryItems: query), as: BookListData.self).data
    }

    public func fetchBookDetail(bookId: Int) async throws -> BookDetail {
        try await client.send(
            APIEndpoint(path: "/books/\(bookId)", usesAuthorizationIfAvailable: true),
            as: BookDetail.self
        ).data
    }

    public func addFavorite(bookId: Int) async throws -> FavoriteStatus {
        try await client.send(
            APIEndpoint(path: "/books/\(bookId)/favorite", method: .post, requiresAuthorization: true),
            as: FavoriteStatus.self
        ).data
    }

    public func removeFavorite(bookId: Int) async throws -> FavoriteStatus {
        try await client.send(
            APIEndpoint(path: "/books/\(bookId)/favorite", method: .delete, requiresAuthorization: true),
            as: FavoriteStatus.self
        ).data
    }

    public func fetchFavoriteBooks(page: Int = 1, size: Int = 20) async throws -> FavoriteBookListData {
        let query = [URLQueryItem(name: "page", value: String(page)), URLQueryItem(name: "size", value: String(size))]
        return try await client.send(
            APIEndpoint(path: "/me/favorite-books", queryItems: query, requiresAuthorization: true),
            as: FavoriteBookListData.self
        ).data
    }
}
