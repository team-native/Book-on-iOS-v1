import Foundation
import Service

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var home: HomeData?
    @Published private(set) var notice: Notice?
    @Published private(set) var recommendations: [BookRecommendation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var noticeFailed = false
    @Published private(set) var recommendationsFailed = false
    @Published private(set) var errorMessage: String?

    private let service: HomeService

    init(service: HomeService) {
        self.service = service
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
        errorMessage = nil

        async let homeRequest: Void = loadHome()
        async let noticesRequest: Void = loadNotices()
        async let recommendationsRequest: Void = loadRecommendations()
        _ = await (homeRequest, noticesRequest, recommendationsRequest)

        isLoading = false
    }

    private func loadHome() async {
        do {
            home = try await service.fetchHome()
        } catch {
            record(error)
        }
    }

    private func loadNotices() async {
        do {
            notice = try await service.fetchNotices(size: 1).items.first
        } catch {
            noticeFailed = true
            record(error)
        }
    }

    private func loadRecommendations() async {
        do {
            recommendations = try await service.fetchTodayRecommendations().items
        } catch {
            recommendationsFailed = true
            record(error)
        }
    }

    private func record(_ error: Error) {
        if errorMessage == nil {
            errorMessage = error.localizedDescription
        }
    }
}
