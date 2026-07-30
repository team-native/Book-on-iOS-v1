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
        let keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return }
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        do { let result = try await service.searchBooks(keyword: keyword, size: 100); books = mergedCopies(result.items); page = result.pagination.page; hasNext = result.pagination.hasNext; self.keyword = keyword }
        catch { books = []; errorMessage = error.localizedDescription }
        isLoading = false
    }
    func loadMoreIfNeeded(currentBook: BookSummary) async {
        guard currentBook.id == books.last?.id, hasNext, !isLoading else { return }
        isLoading = true
        do { let result = try await service.searchBooks(keyword: keyword, page: page + 1, size: 100); books = mergedCopies(books + result.items); page = result.pagination.page; hasNext = result.pagination.hasNext }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    private func mergedCopies(_ items: [BookSummary]) -> [BookSummary] {
        var order: [String] = []
        var grouped: [String: BookSummary] = [:]

        for book in items {
            let isbn = book.isbn?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let key = isbn.isEmpty
                ? "\(book.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())|\(book.author.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())"
                : "isbn:\(isbn)"

            guard let existing = grouped[key] else {
                order.append(key)
                grouped[key] = copy(of: book, totalQuantity: book.totalQuantity, availableQuantity: book.availableQuantity)
                continue
            }

            let representative = existing.availableQuantity == 0 && book.availableQuantity > 0
                ? book
                : existing
            grouped[key] = copy(
                of: representative,
                totalQuantity: existing.totalQuantity + book.totalQuantity,
                availableQuantity: existing.availableQuantity + book.availableQuantity
            )
        }

        return order.compactMap { grouped[$0] }
    }

    private func copy(of book: BookSummary, totalQuantity: Int, availableQuantity: Int) -> BookSummary {
        BookSummary(
            bookId: book.bookId,
            title: book.title,
            author: book.author,
            publisher: book.publisher,
            category: book.category,
            libraryNumber: book.libraryNumber.replacingOccurrences(
                of: #"\s+c\.\d+\s*$"#,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            ),
            coverImageUrl: book.coverImageUrl,
            totalQuantity: totalQuantity,
            availableQuantity: availableQuantity,
            loanAvailable: availableQuantity > 0,
            status: book.status,
            isbn: book.isbn,
            registeredAt: book.registeredAt
        )
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
    @Published var isRequestingLoan = false
    @Published var loanMessage: String?
    @Published var errorMessage: String?
    let bookId: Int
    private let service: BooksService
    private let loanService: LoanService
    init(bookId: Int, service: BooksService, loanService: LoanService = LoanService()) { self.bookId = bookId; self.service = service; self.loanService = loanService }
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
    func requestLoan() async {
        guard !isRequestingLoan else { return }
        isRequestingLoan = true; errorMessage = nil; loanMessage = nil
        do {
            let result = try await loanService.requestLoan(bookId: bookId)
            loanMessage = "대출이 완료됐어요. 반납 예정일은 \(result.dueDate)입니다."
            let value = try? await service.fetchBookDetail(bookId: bookId)
            if let value { book = value }
        } catch { errorMessage = error.localizedDescription }
        isRequestingLoan = false
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
