import Foundation
import Service

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var home: HomeData?
    @Published private(set) var notice: Notice?
    @Published private(set) var recommendationCategories: [BookCategory] = []
    @Published private(set) var selectedRecommendationCategoryCode: String?
    @Published private(set) var recommendedBooks: [BookSummary] = []
    @Published private(set) var newArrivalBooks: [BookSummary] = []
    @Published private(set) var user: MeUser?
    @Published private(set) var isLoading = false
    @Published private(set) var noticeFailed = false
    @Published private(set) var recommendationsFailed = false
    @Published private(set) var recommendationCategoriesFailed = false
    @Published private(set) var newArrivalsFailed = false
    @Published private(set) var isLoadingRecommendations = false
    @Published private(set) var dlsUnavailable = false
    @Published private(set) var dlsMessage: String?
    @Published private(set) var errorMessage: String?

    private let service: HomeService
    private let booksService: BooksService
    private let meService: MeService
    private var recommendationRequestID = UUID()

    init(service: HomeService, booksService: BooksService, meService: MeService) {
        self.service = service
        self.booksService = booksService
        self.meService = meService
    }

    var displayedRecommendations: [BookSummary] {
        recommendedBooks.filter { hasValidCoverImageURL($0.coverImageUrl) }
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        noticeFailed = false
        recommendationsFailed = false
        recommendationCategoriesFailed = false
        newArrivalsFailed = false
        dlsUnavailable = false
        dlsMessage = nil
        errorMessage = nil

        await loadHome()

        async let noticesRequest: Void = loadNotices()
        async let meRequest: Void = loadMe()

        if dlsUnavailable {
            recommendationCategories = []
            recommendedBooks = []
            newArrivalBooks = []
            recommendationsFailed = true
            newArrivalsFailed = true
            _ = await (noticesRequest, meRequest)
        } else {
            async let categoriesRequest = loadRecommendationCategories()
            async let newArrivalsRequest: Void = loadNewArrivals()
            _ = await (noticesRequest, meRequest, newArrivalsRequest)
            recommendationCategories = await categoriesRequest

            let savedCategoryCode = user.flatMap { userDefaultsKey(for: $0.userId) }
                .flatMap { UserDefaults.standard.string(forKey: $0) }
            let validCategoryCode = recommendationCategories.first(where: { $0.code == savedCategoryCode })?.code
            selectedRecommendationCategoryCode = validCategoryCode
            await loadRecommendations(categoryCode: validCategoryCode)
        }

        isLoading = false
    }

    private func loadMe() async {
        user = try? await meService.fetchMe().user
    }

    private func loadRecommendationCategories() async -> [BookCategory] {
        do { return try await booksService.fetchCategories() }
        catch {
            recommendationCategoriesFailed = true
            updateDlsStatus(from: error)
            return []
        }
    }

    private func loadHome() async {
        do {
            home = try await service.fetchHome()
            if let dls = home?.externalServices?.dls, dls.isUnavailable {
                dlsUnavailable = true
                dlsMessage = dls.message
            }
        } catch {
            record(error)
        }
    }

    private func loadNotices() async {
        do {
            notice = try await service.fetchNotices(size: 1).items.first
        } catch {
            noticeFailed = true
        }
    }

    func selectRecommendationCategory(code: String?) async {
        guard code == nil || recommendationCategories.contains(where: { $0.code == code }) else { return }

        selectedRecommendationCategoryCode = code
        if let user, let key = userDefaultsKey(for: user.userId) {
            if let code {
                UserDefaults.standard.set(code, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }

        await loadRecommendations(categoryCode: code)
    }

    private func loadRecommendations(categoryCode: String?) async {
        let requestID = UUID()
        recommendationRequestID = requestID
        isLoadingRecommendations = true
        recommendationsFailed = false
        recommendedBooks = []

        do {
            let items = try await booksService.fetchBooks(
                sort: "POPULAR",
                category: categoryCode,
                size: 30
            ).items
            guard recommendationRequestID == requestID else { return }
            let newArrivalIDs = Set(newArrivalBooks.map(\.bookId))
            recommendedBooks = Array(items.filter { !newArrivalIDs.contains($0.bookId) }.prefix(10))
        } catch {
            guard recommendationRequestID == requestID else { return }
            recommendationsFailed = true
            updateDlsStatus(from: error)
        }

        guard recommendationRequestID == requestID else { return }
        isLoadingRecommendations = false
    }

    private func loadNewArrivals() async {
        do {
            newArrivalBooks = Array(try await booksService.fetchNewBooks(size: 5).items.prefix(5))
        } catch {
            newArrivalsFailed = true
            updateDlsStatus(from: error)
        }
    }

    private func userDefaultsKey(for userId: Int) -> String? {
        guard userId > 0 else { return nil }
        return "home.recommendation.category.user.\(userId)"
    }

    private func updateDlsStatus(from error: Error) {
        guard case let NetworkError.server(_, errorCode, message, _) = error,
              let errorCode,
              5021...5025 ~= errorCode
        else { return }
        dlsUnavailable = true
        dlsMessage = message
    }

    private func hasValidCoverImageURL(_ urlString: String?) -> Bool {
        guard let urlString,
              let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil
        else { return false }

        return true
    }

    private func record(_ error: Error) {
        if errorMessage == nil {
            errorMessage = UserFacingError.message(for: error)
        }
    }
}
