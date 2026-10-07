import SwiftUI
import Service

public struct TodayRecommendationsView: View {
    @State private var books: [BookRecommendation] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let homeService: HomeService
    private let onShowBookDetail: (Int) -> Void

    public init(
        homeService: HomeService = HomeService(),
        onShowBookDetail: @escaping (Int) -> Void = { _ in }
    ) {
        self.homeService = homeService
        self.onShowBookDetail = onShowBookDetail
    }

    public var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 392

            ScrollView {
                Group {
                    if isLoading && books.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 140 * scale)
                    } else if let errorMessage, books.isEmpty {
                        VStack(spacing: 12 * scale) {
                            Text(errorMessage)
                                .multilineTextAlignment(.center)
                            Button("다시 시도") {
                                Task { await load() }
                            }
                        }
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 140 * scale)
                    } else if books.isEmpty {
                        Text("아직 추천 도서가 없어요.")
                            .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                            .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 140 * scale)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 20 * scale), GridItem(.flexible())],
                            spacing: 28 * scale
                        ) {
                            ForEach(books) { book in
                                Button {
                                    onShowBookDetail(book.bookId)
                                } label: {
                                    VStack(alignment: .leading, spacing: 6 * scale) {
                                        BookCoverView(urlString: book.coverImageUrl, width: 156 * scale, height: 218 * scale)
                                        Text(book.title)
                                            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 13 * scale))
                                            .lineLimit(2)
                                        Text(book.author)
                                            .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 10 * scale))
                                            .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 23 * scale)
                        .padding(.top, 8 * scale)
                        .padding(.bottom, 24 * scale)
                    }
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("AI 추천")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
        .task { await load() }
    }

    @MainActor
    private func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            books = try await homeService.fetchTodayRecommendations().items
                .filter { hasValidCoverImageURL($0.coverImageUrl) }
        } catch {
            errorMessage = UserFacingError.message(for: error)
        }
        isLoading = false
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
}

struct TodayRecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        TodayRecommendationsView().previewDevice("iPhone 16")
    }
}
