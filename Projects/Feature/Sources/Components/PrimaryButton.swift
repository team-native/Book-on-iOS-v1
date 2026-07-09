import SwiftUI

struct PrimaryButton: View {
    let title: String
    var scale: CGFloat = 1
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 14 * scale))
                .foregroundColor(.white)
                .frame(width: 300 * scale, height: 52 * scale)
                .background(FeatureAsset.Color.buttonColor.swiftUIColor)
                .cornerRadius(16 * scale)
                .shadow(color: .black.opacity(0.25), radius: 4 * scale, x: 1 * scale, y: 1 * scale)
        }
        .buttonStyle(.plain)
    }
}
