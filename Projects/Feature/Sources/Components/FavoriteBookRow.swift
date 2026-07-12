import SwiftUI

struct FavoriteBookRow: View {
    let title: String
    var scale: CGFloat = 1
    let action: () -> Void
    var body: some View {
        HStack(spacing: 16 * scale) {
            BookThumbnail(width: 54, height: 68, scale: scale, action: {})
                .background(Color(red: 241/255, green: 241/255, blue: 244/255)).clipShape(RoundedRectangle(cornerRadius: 9 * scale))
            VStack(alignment: .leading, spacing: 7 * scale) {
                Text(title).font(FeatureFontFamily.Pretendard.extraBold.swiftUIFont(size: 15 * scale)).foregroundColor(.black)
                Text("로버트 C. 마틴 · 005.1").font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
            }
            Spacer()
            Button(action: action) { Image(systemName: "heart.fill").font(.system(size: 21 * scale)).foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor) }.buttonStyle(.plain)
        }
        .padding(.horizontal, 16 * scale).frame(width: 344 * scale, height: 88 * scale)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16 * scale)).shadow(color: .black.opacity(0.15), radius: 10 * scale, x: scale, y: scale)
    }
}
