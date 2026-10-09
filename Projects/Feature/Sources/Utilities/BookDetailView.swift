import SwiftUI
import Service

public struct BookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: BookDetailViewModel
    private let onBack: (() -> Void)?
    private let showsBackButton: Bool
    private let accentColor = Color(red: 128 / 255, green: 171 / 255, blue: 26 / 255)

    public init(
        bookId: Int,
        booksService: BooksService = BooksService(),
        onBack: (() -> Void)? = nil,
        showsBackButton: Bool = true
    ) {
        _viewModel = StateObject(wrappedValue: BookDetailViewModel(bookId: bookId, service: booksService))
        self.onBack = onBack
        self.showsBackButton = showsBackButton
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / 392, 1.25)
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [Color(red: 248 / 255, green: 253 / 255, blue: 234 / 255), .white, .white],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if let book = viewModel.book {
                    detail(book, scale: scale, availableHeight: geo.size.height)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    errorView(scale: scale)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                if showsBackButton {
                    AppBackButton(scale: scale, action: goBack)
                        .padding(.leading, 23 * scale)
                        .padding(.top, 12 * scale)
                }
            }
        }
        .toolbar(showsBackButton ? .hidden : .visible, for: .navigationBar)
        .navigationBarBackButtonHidden(showsBackButton)
        .preferredColorScheme(.light)
        .alert("관심도서 변경 실패", isPresented: Binding(
            get: { viewModel.favoriteErrorMessage != nil },
            set: { if !$0 { viewModel.favoriteErrorMessage = nil } }
        )) {
            Button("확인", role: .cancel) { viewModel.favoriteErrorMessage = nil }
        } message: {
            Text(viewModel.favoriteErrorMessage ?? "잠시 후 다시 시도해 주세요.")
        }
        .task { await viewModel.load() }
    }

    private func goBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private func detail(_ book: BookDetail, scale: CGFloat, availableHeight: CGFloat) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                cover(book, scale: scale, availableHeight: availableHeight)
                VStack(alignment: .leading, spacing: 8 * scale) {
                    Text(book.title)
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 24 * scale))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(book.author).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale)).foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    stats(book, scale: scale).padding(.top, 18 * scale)
                    Text("책 소개").font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale)).padding(.top, 26 * scale)
                    Text(book.description ?? "등록된 책 소개가 없습니다.").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).lineSpacing(4 * scale).padding(.top, 6 * scale)
                }.padding(.horizontal, 23 * scale).padding(.top, 20 * scale).padding(.bottom, 40 * scale)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar(scale: scale)
        }
    }

    private func cover(_ book: BookDetail, scale: CGFloat, availableHeight: CGFloat) -> some View {
        let height = min(420 * scale, max(340 * scale, availableHeight * 0.5))

        return LinearGradient(
            colors: [Color(red: 248 / 255, green: 253 / 255, blue: 234 / 255), .white],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: height)
        .overlay {
            BookCoverView(
                urlString: book.coverImageUrl,
                width: 216 * scale,
                height: 282 * scale,
                cornerRadius: 0,
                contentMode: .fit
            )
            .shadow(color: .black.opacity(0.2), radius: 5 * scale, y: 4 * scale)
            .offset(y: 20 * scale)
        }
    }

    private func stats(_ book: BookDetail, scale: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 12 * scale) {
            BookDetailStat(title: "도서관 번호", value: book.libraryNumber, scale: scale)
            BookDetailStat(
                title: "재고 수량",
                value: "전체 \(book.totalQuantity)권\n대출 가능 \(book.availableQuantity)권",
                scale: scale
            )
            BookDetailStat(
                title: "대출 여부",
                value: book.loanAvailable ? "대출 가능" : "대출 불가",
                valueColor: book.loanAvailable ? accentColor : .black,
                scale: scale
            )
        }
    }

    private var favoriteLabel: String {
        viewModel.isFavorite ? "관심도서 추가완료" : "관심도서 추가"
    }

    private func toggleFavorite() {
        Task { await viewModel.toggleFavorite() }
    }

    private func bottomBar(scale: CGFloat) -> some View {
        HStack(spacing: 12 * scale) {
            Button(action: toggleFavorite) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 22 * scale))
                    .foregroundColor(Color(red: 1, green: 0.3, blue: 0.35))
                    .frame(width: 44 * scale, height: 60 * scale)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel(viewModel.isFavorite ? "관심도서 해제" : "관심도서 추가")
            .accessibilityValue(viewModel.isFavorite ? "추가됨" : "추가 안 됨")

            Button(action: toggleFavorite) {
                ZStack {
                    Text(favoriteLabel)
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 16 * scale))
                        .opacity(viewModel.isUpdatingFavorite ? 0 : 1)
                    if viewModel.isUpdatingFavorite { ProgressView().tint(.white) }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60 * scale)
                .background(accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 20 * scale))
                .shadow(color: .black.opacity(0.16), radius: 3 * scale, y: 3 * scale)
            }
            .accessibilityLabel(favoriteLabel)
            .accessibilityHint(viewModel.isFavorite ? "누르면 관심도서에서 해제합니다" : "누르면 관심도서에 추가합니다")
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isUpdatingFavorite)
        .padding(.horizontal, 23 * scale)
        .padding(.vertical, 12 * scale)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(alignment: .top) { Divider() }
    }

    private func errorView(scale: CGFloat) -> some View {
        VStack(spacing: 12 * scale) {
            Text(viewModel.errorMessage ?? "도서 정보를 불러오지 못했어요")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 15 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

            Button("재시도") {
                Task { await viewModel.load() }
            }
            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
            .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
        }
        .multilineTextAlignment(.center)
    }
}

struct BookDetailView_Previews: PreviewProvider { static var previews: some View { BookDetailView(bookId: 1).previewDevice("iPhone 16") } }
