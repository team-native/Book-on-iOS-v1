import SwiftUI

struct InlineErrorText: View {
    let message: String
    var scale: CGFloat = 1

    var body: some View {
        Text(message)
            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale))
            .foregroundColor(FeatureAsset.Color.textWarning.swiftUIColor)
    }
}
