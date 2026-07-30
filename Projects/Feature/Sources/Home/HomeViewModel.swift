import Foundation
import Service

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var home: HomeData?
    @Published private(set) var notice: Notice?
    @Published private(set) var recommendations: [BookRecommendation] = []
    @Published private(set) var popularBooks: [BookSummary] = []
    @Published private(set) var user: MeUser?
    @Published private(set) var isLoading = false
    @Published private(set) var noticeFailed = false
    @Published private(set) var recommendationsFailed = false
    @Published private(set) var popularBooksFailed = false
    @Published private(set) var dlsUnavailable = false
    @Published private(set) var dlsMessage: String?
    @Published private(set) var errorMessage: String?

    private let service: HomeService
    private let booksService: BooksService
    private let meService: MeService

    init(service: HomeService, booksService: BooksService, meService: MeService) {
        self.service = service
        self.booksService = booksService
        self.meService = meService
    }

    var displayedRecommendations: [BookRecommendation] {
        if !recommendations.isEmpty {
            return recommendations
        }
        return home?.todayRecommendation.map { [$0] } ?? []
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        noticeFailed = false
        recommendationsFailed = false
        popularBooksFailed = false
        dlsUnavailable = false
        dlsMessage = nil
        errorMessage = nil

        await loadHome()

        async let noticesRequest: Void = loadNotices()
        async let meRequest: Void = loadMe()

        if dlsUnavailable {
            recommendations = []
            popularBooks = []
            recommendationsFailed = true
            popularBooksFailed = true
            _ = await (noticesRequest, meRequest)
        } else {
            async let recommendationsRequest: Void = loadRecommendations()
            async let popularRequest: Void = loadPopularBooks()
            _ = await (noticesRequest, meRequest, recommendationsRequest, popularRequest)
        }

        isLoading = false
    }

    private func loadMe() async {
        user = try? await meService.fetchMe().user
    }

    private func loadPopularBooks() async {
        do { popularBooks = try await booksService.fetchBooks(sort: "POPULAR", size: 10).items }
        catch {
            popularBooksFailed = true
            updateDlsStatus(from: error)
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

    private func loadRecommendations() async {
        do {
            recommendations = try await service.fetchTodayRecommendations().items
        } catch {
            recommendationsFailed = true
            updateDlsStatus(from: error)
        }
    }

    private func updateDlsStatus(from error: Error) {
        guard case let NetworkError.server(_, errorCode, message, _) = error,
              let errorCode,
              5021...5025 ~= errorCode
        else { return }
        dlsUnavailable = true
        dlsMessage = message
    }

    private func record(_ error: Error) {
        if errorMessage == nil {
            errorMessage = error.localizedDescription
        }
    }
}
