import SwiftUI
import Service

struct FavoriteBookRow: View {
    let book: FavoriteBook
    var scale: CGFloat = 1
    let onSelect: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 16 * scale) {
            Button(action: onSelect) {
                HStack(spacing: 16 * scale) {
                    BookCoverView(urlString: nil, width: 54 * scale, height: 68 * scale)
                    VStack(alignment: .leading, spacing: 7 * scale) {
                        Text(book.title).font(FeatureFontFamily.Pretendard.extraBold.swiftUIFont(size: 15 * scale)).foregroundColor(.black)
                        Text("\(book.author) · \(book.libraryNumber)").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    }
                }
            }.buttonStyle(.plain)
            Spacer()
            Button(action: onRemove) { Image(systemName: "heart.fill").font(.system(size: 21 * scale)).foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor) }.buttonStyle(.plain)
        }.padding(.horizontal, 16 * scale).frame(width: 344 * scale, height: 88 * scale).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16 * scale)).shadow(color: .black.opacity(0.15), radius: 10 * scale, x: scale, y: scale)
    }
}
