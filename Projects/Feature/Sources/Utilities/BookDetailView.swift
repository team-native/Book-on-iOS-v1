import SwiftUI
import Service

public struct BookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: BookDetailViewModel
    private let onBack: (() -> Void)?

    public init(bookId: Int, booksService: BooksService = BooksService(), onBack: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: BookDetailViewModel(bookId: bookId, service: booksService))
        self.onBack = onBack
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()
                if viewModel.isLoading { ProgressView() }
                else if let book = viewModel.book { detail(book, scale: scale) }
                else { errorView(scale: scale) }
                AppBackButton(scale: scale, action: goBack).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(.leading, 23 * scale).padding(.top, 64 * scale)
            }
        }.ignoresSafeArea().task { await viewModel.load() }
    }

    private func goBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private func detail(_ book: BookDetail, scale: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Color(red: 248/255, green: 255/255, blue: 232/255)
                        .frame(height: 420 * scale)
                        .overlay(BookCoverView(urlString: book.coverImageUrl, width: 160 * scale, height: 240 * scale).shadow(radius: 8 * scale))
                    VStack(alignment: .leading, spacing: 8 * scale) {
                        Text(book.title).font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 24 * scale))
                        Text(book.author).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale)).foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                        HStack(spacing: 12 * scale) {
                            BookDetailStat(title: "도서관 번호", value: book.libraryNumber, scale: scale)
                            BookDetailStat(title: "재고 수량", value: "\(book.availableQuantity)권", scale: scale)
                            BookDetailStat(title: "대출 여부", value: book.loanAvailable ? "가능" : "불가", isHighlighted: book.loanAvailable, scale: scale)
                        }.padding(.top, 18 * scale)
                        Text("책 소개").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale)).padding(.top, 26 * scale)
                        Text(book.description ?? "등록된 책 소개가 없습니다.").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).lineSpacing(4 * scale).padding(.top, 6 * scale)
                        if let error = viewModel.errorMessage { Text(error).font(.caption).foregroundColor(.red).padding(.top, 8 * scale) }
                    }.padding(.horizontal, 23 * scale).padding(.top, 20 * scale).padding(.bottom, 120 * scale)
                }
            }
            bottomBar(scale: scale)
        }
    }

    private func bottomBar(scale: CGFloat) -> some View {
        HStack {
            Button { Task { await viewModel.toggleFavorite() } } label: {
                HStack(spacing: 8 * scale) {
                    if viewModel.isUpdatingFavorite {
                        ProgressView()
                    } else {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20 * scale))
                            .foregroundColor(.red)
                        Text(viewModel.isFavorite ? "관심 도서 해제" : "관심 도서 추가")
                            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 16 * scale))
                            .foregroundColor(.black)
                    }
                }
                .frame(width: 300 * scale, height: 60 * scale)
                .background(Color(red: 241 / 255, green: 241 / 255, blue: 244 / 255))
                .clipShape(RoundedRectangle(cornerRadius: 20 * scale))
            }.disabled(viewModel.isUpdatingFavorite)
        }.frame(maxWidth: .infinity).frame(height: 100 * scale).background(Color.white).overlay(alignment: .top) { Divider() }
    }

    private func errorView(scale: CGFloat) -> some View {
        VStack(spacing: 12 * scale) { Text(viewModel.errorMessage ?? "도서 정보를 불러오지 못했어요"); Button("재시도") { Task { await viewModel.load() } } }.multilineTextAlignment(.center)
    }
}

struct BookDetailView_Previews: PreviewProvider { static var previews: some View { BookDetailView(bookId: 1).previewDevice("iPhone 16") } }
