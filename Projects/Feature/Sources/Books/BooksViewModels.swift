import Foundation
import Service

private struct PagingState {
    private(set) var page = 1
    private(set) var hasNext = false

    var nextPage: Int { page + 1 }

    mutating func update(from pagination: Pagination) {
        page = pagination.page
        hasNext = pagination.hasNext
    }
}

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var books: [BookSummary] = []
    @Published var categories: [BookCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let service: BooksService
    private var paging = PagingState()
    private var lastSort = "POPULAR"
    private var lastCategory: String?
    private var loadRequestID = UUID()
    init(service: BooksService) { self.service = service }
    func load(sort: String, category: String?) async {
        let requestID = UUID()
        loadRequestID = requestID
        if lastSort != sort || lastCategory != category {
            books = []
            paging = PagingState()
        }
        isLoading = true; errorMessage = nil
        async let bookData = service.fetchBooks(sort: sort, category: category)
        async let categoryData = service.fetchCategories()
        do {
            let result = try await bookData
            if loadRequestID == requestID {
                books = result.items; paging.update(from: result.pagination)
                lastSort = sort; lastCategory = category
            }
        } catch {
            if loadRequestID == requestID { errorMessage = UserFacingError.message(for: error) }
        }
        do {
            let result = try await categoryData
            if loadRequestID == requestID { categories = result }
        } catch {
            if loadRequestID == requestID, errorMessage == nil { errorMessage = UserFacingError.message(for: error) }
        }
        if loadRequestID == requestID { isLoading = false }
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, paging.hasNext, !isLoading else { return }
        let requestID = loadRequestID
        isLoading = true
        do {
            let result = try await service.fetchBooks(sort: lastSort, category: lastCategory, page: paging.nextPage)
            if loadRequestID == requestID {
                books += result.items; paging.update(from: result.pagination)
            }
        } catch {
            if loadRequestID == requestID { errorMessage = UserFacingError.message(for: error) }
        }
        if loadRequestID == requestID { isLoading = false }
    }
}

@MainActor
final class SearchBooksViewModel: ObservableObject {
    @Published var books: [BookSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let service: BooksService
    private var paging = PagingState()
    private var keyword = ""
    private var searchRequestID = UUID()
    init(service: BooksService) { self.service = service }
    func search(_ keyword: String) async {
        let keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return }
        let requestID = UUID()
        searchRequestID = requestID
        self.keyword = keyword
        books = []
        paging = PagingState()
        isLoading = true; errorMessage = nil
        do {
            let result = try await service.searchBooks(keyword: keyword, size: 100)
            guard searchRequestID == requestID else { return }
            books = result.items; paging.update(from: result.pagination); self.keyword = keyword
        } catch {
            guard searchRequestID == requestID else { return }
            books = []; errorMessage = UserFacingError.message(for: error)
        }
        if searchRequestID == requestID { isLoading = false }
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, paging.hasNext, !isLoading else { return }
        let requestID = searchRequestID
        isLoading = true
        do {
            let result = try await service.searchBooks(keyword: keyword, page: paging.nextPage, size: 100)
            if searchRequestID == requestID {
                books += result.items; paging.update(from: result.pagination)
            }
        } catch {
            if searchRequestID == requestID { errorMessage = UserFacingError.message(for: error) }
        }
        if searchRequestID == requestID { isLoading = false }
    }
}

@MainActor
final class NewBooksViewModel: ObservableObject {
    @Published var books: [BookSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let service: BooksService
    private var paging = PagingState()
    init(service: BooksService) { self.service = service }
    func load() async {
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        do { let result = try await service.fetchNewBooks(); books = result.items; paging.update(from: result.pagination) }
        catch { errorMessage = UserFacingError.message(for: error) }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, paging.hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.fetchNewBooks(page: paging.nextPage); books += result.items; paging.update(from: result.pagination) }
        catch { errorMessage = UserFacingError.message(for: error) }
        isLoading = false
    }
}

@MainActor
final class BookDetailViewModel: ObservableObject {
    @Published var book: BookDetail?
    @Published var isFavorite = false
    @Published var isLoading = false
    @Published var isUpdatingFavorite = false
    @Published var errorMessage: String?
    @Published var favoriteErrorMessage: String?
    let bookId: Int
    private let service: BooksService
    init(bookId: Int, service: BooksService) {
        self.bookId = bookId
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let value = try await service.fetchBookDetail(bookId: bookId)
            book = value
            isFavorite = value.favorite
        } catch {
            errorMessage = UserFacingError.message(for: error)
        }
    }

    func toggleFavorite() async {
        guard !isUpdatingFavorite else { return }
        isUpdatingFavorite = true
        favoriteErrorMessage = nil
        defer { isUpdatingFavorite = false }

        do {
            let result: FavoriteStatus
            if isFavorite {
                result = try await service.removeFavorite(bookId: bookId)
            } else {
                result = try await service.addFavorite(bookId: bookId)
            }
            isFavorite = result.favorite
        } catch {
            favoriteErrorMessage = UserFacingError.message(for: error)
        }
    }
}

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var books: [FavoriteBook] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let service: BooksService
    private var paging = PagingState()
    init(service: BooksService) { self.service = service }
    func load() async {
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        do { let result = try await service.fetchFavoriteBooks(); books = result.items; paging.update(from: result.pagination) }
        catch { errorMessage = UserFacingError.message(for: error) }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: FavoriteBook) async {
        guard currentBook.id == books.last?.id, paging.hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.fetchFavoriteBooks(page: paging.nextPage); books += result.items; paging.update(from: result.pagination) }
        catch { errorMessage = UserFacingError.message(for: error) }
        isLoading = false
    }
    func remove(_ book: FavoriteBook) async {
        do { _ = try await service.removeFavorite(bookId: book.bookId); books.removeAll { $0.bookId == book.bookId } }
        catch { errorMessage = UserFacingError.message(for: error) }
    }
}
