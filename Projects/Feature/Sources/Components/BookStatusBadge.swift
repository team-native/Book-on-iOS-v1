import SwiftUI

struct BookStatusBadge: View {
    let title: String
    var scale: CGFloat = 1
    var body: some View { Text(title).font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 11 * scale)).foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor).padding(.horizontal, 9 * scale).frame(height: 24 * scale).background(FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.12)).clipShape(Capsule()) }
}
