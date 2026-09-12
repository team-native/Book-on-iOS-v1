import SwiftUI
import Service

public struct MainHomeView: View {
    @State private var searchText = ""
    @StateObject private var viewModel: HomeViewModel
    private let onSelectTab: (BottomTabBar.Item) -> Void
    private let onShowSearch: () -> Void
    private let onShowNotifications: () -> Void
    private let onShowNotices: () -> Void
    private let onShowNewArrivals: () -> Void
    private let onShowBookDetail: (Int) -> Void

    public init(
        homeService: HomeService = HomeService(),
        booksService: BooksService = BooksService(),
        meService: MeService = MeService(),
        onSelectTab: @escaping (BottomTabBar.Item) -> Void = { _ in },
        onShowSearch: @escaping () -> Void = {},
        onShowNotifications: @escaping () -> Void = {},
        onShowNotices: @escaping () -> Void = {},
        onShowNewArrivals: @escaping () -> Void = {},
        onShowBookDetail: @escaping (Int) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(service: homeService, booksService: booksService, meService: meService))
        self.onSelectTab = onSelectTab
        self.onShowSearch = onShowSearch
        self.onShowNotifications = onShowNotifications
        self.onShowNotices = onShowNotices
        self.onShowNewArrivals = onShowNewArrivals
        self.onShowBookDetail = onShowBookDetail
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392

            ZStack(alignment: .bottom) {
                Color(red: 251 / 255, green: 251 / 255, blue: 252 / 255)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        header(scale: scale)

                        BookSearchField(
                            text: $searchText,
                            scale: scale,
                            onSearch: onShowSearch,
                            onActivate: onShowSearch
                        )
                        .padding(.top, 20 * scale)

                        if let errorMessage = viewModel.errorMessage,
                           viewModel.home == nil,
                           viewModel.notice == nil,
                           viewModel.displayedRecommendations.isEmpty {
                            errorBanner(message: errorMessage, scale: scale)
                                .padding(.top, 10 * scale)
                        }

                        Button(action: onShowNotices) { noticeCard(scale: scale) }
                            .buttonStyle(.plain)
                            .padding(.top, 19 * scale)

                        recommendationSection(scale: scale)
                            .padding(.top, 40 * scale)

                        popularSection(scale: scale)
                            .padding(.top, 34 * scale)
                    }
                    .padding(.top, 66 * scale)
                    .padding(.horizontal, 27 * scale)
                    .padding(.bottom, 112 * scale)
                }

            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .task {
            await viewModel.load()
        }
    }

    private func header(scale: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    Text(greeting(for: context.date))
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                        .foregroundColor(Color(red: 154 / 255, green: 154 / 255, blue: 161 / 255))
                        .frame(height: 20 * scale, alignment: .topLeading)
                }
                Text("\(viewModel.user?.name ?? "사용자")님")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 24 * scale))
                    .foregroundColor(.black)
                    .padding(.top, 5 * scale)
            }

            Button(action: onShowNotifications) {
                Image(systemName: "bell")
                    .font(.system(size: 17 * scale, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 32 * scale, height: 32 * scale)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 7 * scale))
                    .shadow(color: .black.opacity(0.1), radius: 3 * scale, x: 1 * scale, y: 1 * scale)
                    .overlay(alignment: .topTrailing) {
                        Circle().fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                            .frame(width: 4 * scale, height: 4 * scale)
                            .padding(7 * scale)
                    }
            }
            .buttonStyle(.plain)
            .offset(x: 256 * scale, y: 10 * scale)

            Button(action: { onSelectTab(.my) }) {
                Image(systemName: "person.fill")
                    .font(.system(size: 18 * scale))
                    .foregroundColor(.white)
                    .frame(width: 36 * scale, height: 36 * scale)
                    .background(Color(red: 216 / 255, green: 216 / 255, blue: 218 / 255))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
                .offset(x: 304 * scale, y: 10 * scale)
        }
        .frame(width: 340 * scale, height: 50 * scale, alignment: .topLeading)
    }

    private func greeting(for date: Date) -> String {
        switch Calendar.current.component(.hour, from: date) {
        case 5..<12:
            return "좋은 아침이에요"
        case 12..<15:
            return "좋은 점심이에요"
        case 15..<18:
            return "좋은 오후예요"
        default:
            return "좋은 저녁이에요"
        }
    }

    private func noticeCard(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12 * scale) {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 16 * scale, weight: .medium))
                    .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                    .frame(width: 36 * scale, height: 36 * scale)
                    .background(FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 10 * scale))
                VStack(alignment: .leading, spacing: 4 * scale) {
                    Text("도서부 공지").font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                    Text(viewModel.notice?.createdAt ?? (viewModel.isLoading ? "불러오는 중..." : "새 공지 없음"))
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 10 * scale))
                        .foregroundColor(Color(red: 154 / 255, green: 154 / 255, blue: 161 / 255))
                }
                Spacer()
                Text("NEW")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 10 * scale))
                    .foregroundColor(.white)
                    .frame(width: 43 * scale, height: 21 * scale)
                    .background(FeatureAsset.Color.buttonColor.swiftUIColor)
                    .clipShape(RoundedRectangle(cornerRadius: 7 * scale))
            }
            Text(viewModel.notice?.title ?? (viewModel.noticeFailed ? "공지를 불러오지 못했어요" : "등록된 공지가 없어요"))
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 16 * scale))
                .padding(.top, 18 * scale)
            Text(viewModel.notice?.summary ?? (viewModel.noticeFailed ? "잠시 후 다시 시도해주세요." : "새로운 도서부 공지가 등록되면 이곳에 표시됩니다."))
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                .foregroundColor(Color(red: 122 / 255, green: 122 / 255, blue: 129 / 255))
                .lineSpacing(4 * scale)
                .padding(.top, 12 * scale)
            HStack(spacing: 8 * scale) {
                Text("자세히 보기")
                Image(systemName: "chevron.right").font(.system(size: 8 * scale, weight: .bold))
            }
            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
            .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
            .padding(.top, 11 * scale)
        }
        .padding(.horizontal, 18 * scale)
        .padding(.top, 18 * scale)
        .frame(width: 340 * scale, height: 184 * scale, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20 * scale))
        .shadow(color: .black.opacity(0.15), radius: 10 * scale, x: 1 * scale, y: 1 * scale)
    }

    private func recommendationSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8 * scale) {
                Text("도서 추천")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 20 * scale))
                HStack(spacing: 4 * scale) {
                    Image(systemName: "sparkles").font(.system(size: 8 * scale))
                    Text("AI 추천")
                }
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale))
                .foregroundColor(.white)
                .frame(width: 58 * scale, height: 22 * scale)
                .background(LinearGradient(colors: [Color(red: 147/255, green: 210/255, blue: 52/255), Color(red: 116/255, green: 163/255, blue: 46/255)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 8 * scale))
                Spacer()
                Button("더보기", action: onShowNewArrivals)
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
            }
            Text("학교 도서관의 대출 통계를 기반으로 골랐어요")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                .foregroundColor(Color(red: 154 / 255, green: 154 / 255, blue: 161 / 255))
                .padding(.top, 4 * scale)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 32 * scale) {
                    if viewModel.isLoading && viewModel.displayedRecommendations.isEmpty {
                        ProgressView()
                            .frame(width: 338 * scale, height: 220 * scale)
                    } else if viewModel.displayedRecommendations.isEmpty {
                        Text(
                            viewModel.dlsUnavailable
                                ? "학교 도서관 연결이 원활하지 않아요.\n잠시 후 다시 시도해주세요."
                                : (viewModel.recommendationsFailed ? "추천 도서를 불러오지 못했어요." : "아직 추천 도서가 없어요.")
                        )
                            .multilineTextAlignment(.center)
                            .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                            .foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
                            .frame(width: 338 * scale, height: 160 * scale, alignment: .center)
                    } else {
                        ForEach(viewModel.displayedRecommendations) { book in
                            bookSlot(book: book, scale: scale)
                        }
                    }
                }
                .padding(.leading, 27 * scale)
                .padding(.trailing, 27 * scale)
            }
            .padding(.horizontal, -27 * scale)
            .padding(.top, 13 * scale)
        }
        .frame(width: 338 * scale, alignment: .leading)
    }

    private func bookSlot(book: BookRecommendation, scale: CGFloat) -> some View {
        Button(action: { onShowBookDetail(book.bookId) }) {
            VStack(alignment: .leading, spacing: 0) {
                AsyncImage(url: book.coverImageUrl.flatMap(URL.init(string:))) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 4 * scale)
                        .fill(Color(red: 235/255, green: 235/255, blue: 235/255))
                        .overlay(Image(systemName: "book.closed").foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor))
                }
                .frame(width: 94 * scale, height: 160 * scale)
                .clipped()
                Text(book.title)
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .lineLimit(2)
                    .frame(width: 118 * scale, alignment: .leading)
                    .padding(.top, 18 * scale)
                Text(book.author)
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(Color(red: 152/255, green: 152/255, blue: 159/255))
                    .padding(.top, 4 * scale)
            }
        }
        .buttonStyle(.plain)
    }

    private func errorBanner(message: String, scale: CGFloat) -> some View {
        HStack(spacing: 8 * scale) {
            Image(systemName: "exclamationmark.circle")
            Text(message).lineLimit(2)
            Spacer(minLength: 0)
            Button("재시도") {
                Task { await viewModel.load() }
            }
        }
        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 11 * scale))
        .foregroundColor(Color(red: 142/255, green: 71/255, blue: 71/255))
        .padding(10 * scale)
        .frame(width: 338 * scale)
        .background(Color(red: 255/255, green: 241/255, blue: 241/255))
        .clipShape(RoundedRectangle(cornerRadius: 10 * scale))
    }

    private func popularSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 14 * scale) {
            HStack {
                Text("우리 학교 인기 책")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                Spacer()
                Button("더보기", action: onShowNewArrivals)
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16 * scale) {
                    if viewModel.isLoading && viewModel.popularBooks.isEmpty {
                        ProgressView().frame(width: 338 * scale, height: 76 * scale)
                    } else if viewModel.popularBooks.isEmpty {
                        Text(
                            viewModel.dlsUnavailable
                                ? "학교 도서관 연결이 원활하지 않아요."
                                : (viewModel.popularBooksFailed ? "인기 도서를 불러오지 못했어요." : "아직 인기 도서가 없어요.")
                        )
                            .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                            .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                            .frame(width: 338 * scale, height: 76 * scale)
                    } else {
                        ForEach(viewModel.popularBooks) { book in popularBook(book: book, scale: scale) }
                    }
                }
                .padding(.leading, 27 * scale)
                .padding(.vertical, 2 * scale)
                .padding(.trailing, 27 * scale)
            }
            .padding(.horizontal, -27 * scale)
        }
        .frame(width: 338 * scale)
    }

    private func popularBook(book: BookSummary, scale: CGFloat) -> some View {
        Button(action: { onShowBookDetail(book.bookId) }) {
            HStack(spacing: 8 * scale) {
                BookCoverView(urlString: book.coverImageUrl, width: 50 * scale, height: 64 * scale, cornerRadius: 10 * scale)
                VStack(alignment: .leading, spacing: 10 * scale) {
                    Text(book.title)
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                        .foregroundColor(.black)
                    Text("\(book.author) · 재고 \(book.availableQuantity)권")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 10 * scale))
                        .foregroundColor(Color(red: 176/255, green: 176/255, blue: 181/255))
                }
                Spacer(minLength: 0)
            }
            .padding(6 * scale)
            .frame(width: 206 * scale, height: 76 * scale)
            .background(Color(red: 251/255, green: 251/255, blue: 252/255))
            .clipShape(RoundedRectangle(cornerRadius: 12 * scale))
            .shadow(color: .black.opacity(0.15), radius: 9 * scale, x: scale, y: scale)
        }
        .buttonStyle(.plain)
    }

}

struct MainHomeView_Previews: PreviewProvider {
    static var previews: some View { MainHomeView().previewDevice("iPhone 16") }
}
