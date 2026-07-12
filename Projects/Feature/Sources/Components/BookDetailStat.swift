import SwiftUI

struct BookDetailStat: View {
    let title: String
    let value: String
    var isHighlighted = false
    var scale: CGFloat = 1
    var body: some View {
        VStack(spacing: 7 * scale) {
            Text(title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale)).foregroundColor(Color(red: 154/255, green: 154/255, blue: 161/255))
            Text(value).font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale)).foregroundColor(isHighlighted ? FeatureAsset.Color.buttonColor.swiftUIColor : .black)
        }
        .frame(width: 108 * scale, height: 68 * scale)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12 * scale)).shadow(color: .black.opacity(0.08), radius: 12 * scale, x: scale, y: scale)
    }
}
