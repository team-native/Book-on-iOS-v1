import Foundation
import Service

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var books: [BookSummary] = []
    @Published var categories: [BookCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let service: BooksService
    private var page = 1
    private var hasNext = false
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
            books = result.items; page = result.pagination.page; hasNext = result.pagination.hasNext
            lastSort = sort; lastCategory = category
        } catch { errorMessage = error.localizedDescription }
        do { categories = try await categoryData }
        catch { if errorMessage == nil { errorMessage = error.localizedDescription } }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.fetchBooks(sort: lastSort, category: lastCategory, page: page + 1); books += result.items; page = result.pagination.page; hasNext = result.pagination.hasNext }
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
    private var page = 1
    private var hasNext = false
    private var keyword = ""
    init(service: BooksService) { self.service = service }
    func search(_ keyword: String) async {
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        do { let result = try await service.searchBooks(keyword: keyword); books = result.items; page = result.pagination.page; hasNext = result.pagination.hasNext; self.keyword = keyword }
        catch { books = []; errorMessage = error.localizedDescription }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.searchBooks(keyword: keyword, page: page + 1); books += result.items; page = result.pagination.page; hasNext = result.pagination.hasNext }
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
    private var page = 1
    private var hasNext = false
    init(service: BooksService) { self.service = service }
    func load() async {
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        do { let result = try await service.fetchNewBooks(); books = result.items; page = result.pagination.page; hasNext = result.pagination.hasNext }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.fetchNewBooks(page: page + 1); books += result.items; page = result.pagination.page; hasNext = result.pagination.hasNext }
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
    private var page = 1
    private var hasNext = false
    init(service: BooksService) { self.service = service }
    func load() async {
        isLoading = true; errorMessage = nil
        do { let result = try await service.fetchFavoriteBooks(); books = result.items; page = result.pagination.page; hasNext = result.pagination.hasNext }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: FavoriteBook) async {
        guard currentBook.id == books.last?.id, hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.fetchFavoriteBooks(page: page + 1); books += result.items; page = result.pagination.page; hasNext = result.pagination.hasNext }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
    func remove(_ book: FavoriteBook) async {
        do { _ = try await service.removeFavorite(bookId: book.bookId); books.removeAll { $0.bookId == book.bookId } }
        catch { errorMessage = error.localizedDescription }
    }
}
