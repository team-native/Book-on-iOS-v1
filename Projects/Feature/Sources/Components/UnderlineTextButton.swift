import SwiftUI

struct UnderlineTextButton: View {
    let title: String
    var scale: CGFloat = 1
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                .underline()
        }
        .buttonStyle(.plain)
    }
}
