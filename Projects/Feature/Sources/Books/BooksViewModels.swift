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
    init(service: BooksService) { self.service = service }
    func load(sort: String, category: String?) async {
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        async let bookData = service.fetchBooks(sort: sort, category: category)
        async let categoryData = service.fetchCategories()
        do {
            let result = try await bookData
            books = result.items; paging.update(from: result.pagination)
            lastSort = sort; lastCategory = category
        } catch { errorMessage = error.localizedDescription }
        do { categories = try await categoryData }
        catch { if errorMessage == nil { errorMessage = error.localizedDescription } }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, paging.hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.fetchBooks(sort: lastSort, category: lastCategory, page: paging.nextPage); books += result.items; paging.update(from: result.pagination) }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
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
    init(service: BooksService) { self.service = service }
    func search(_ keyword: String) async {
        let keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return }
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        do { let result = try await service.searchBooks(keyword: keyword, size: 100); books = result.items; paging.update(from: result.pagination); self.keyword = keyword }
        catch { books = []; errorMessage = error.localizedDescription }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, paging.hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.searchBooks(keyword: keyword, page: paging.nextPage, size: 100); books += result.items; paging.update(from: result.pagination) }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
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
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, paging.hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.fetchNewBooks(page: paging.nextPage); books += result.items; paging.update(from: result.pagination) }
        catch { errorMessage = error.localizedDescription }
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
    let bookId: Int
    private let service: BooksService
    init(bookId: Int, service: BooksService) { self.bookId = bookId; self.service = service }
    func load() async {
        isLoading = true; errorMessage = nil
        do { let value = try await service.fetchBookDetail(bookId: bookId); book = value; isFavorite = value.favorite }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
    func toggleFavorite() async {
        guard !isUpdatingFavorite else { return }
        isUpdatingFavorite = true; errorMessage = nil
        do {
            let result = isFavorite ? try await service.removeFavorite(bookId: bookId) : try await service.addFavorite(bookId: bookId)
            isFavorite = result.favorite
        } catch { errorMessage = error.localizedDescription }
        isUpdatingFavorite = false
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
        isLoading = true; errorMessage = nil
        do { let result = try await service.fetchFavoriteBooks(); books = result.items; paging.update(from: result.pagination) }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: FavoriteBook) async {
        guard currentBook.id == books.last?.id, paging.hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.fetchFavoriteBooks(page: paging.nextPage); books += result.items; paging.update(from: result.pagination) }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
    func remove(_ book: FavoriteBook) async {
        do { _ = try await service.removeFavorite(bookId: book.bookId); books.removeAll { $0.bookId == book.bookId } }
        catch { errorMessage = error.localizedDescription }
    }
}
