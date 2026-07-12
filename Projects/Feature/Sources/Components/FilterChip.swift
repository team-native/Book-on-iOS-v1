import SwiftUI

struct FilterChip: View {
    let title: String
    var isSelected = false
    var scale: CGFloat = 1
    let action: () -> Void
    var body: some View { Button(action: action) { Text(title).font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale)).foregroundColor(isSelected ? .white : FeatureAsset.Color.textDescription.swiftUIColor).padding(.horizontal, 14 * scale).frame(height: 34 * scale).background(isSelected ? FeatureAsset.Color.buttonColor.swiftUIColor : Color.white).clipShape(Capsule()) }.buttonStyle(.plain) }
}
