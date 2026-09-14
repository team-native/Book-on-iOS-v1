import SwiftUI

public struct NotificationInboxView: View {
    private let onDismiss: () -> Void

    public init(onDismiss: @escaping () -> Void = {}) {
        self.onDismiss = onDismiss
    }

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 392

            ZStack(alignment: .topLeading) {
                Color(red: 251 / 255, green: 251 / 255, blue: 252 / 255)
                    .ignoresSafeArea()

                header(scale: scale)
                    .padding(.top, 58 * scale)

                ScrollView(showsIndicators: false) {
                    emptyState(scale: scale)
                    .padding(.horizontal, 24 * scale)
                    .padding(.top, 150 * scale)
                    .padding(.bottom, 32 * scale)
                }
                .padding(.top, 118 * scale)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func header(scale: CGFloat) -> some View {
        HStack(spacing: 0) {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16 * scale, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 40 * scale, height: 40 * scale)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text("받은 알림")
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 20 * scale))
                .foregroundColor(.black)
                .padding(.leading, 8 * scale)

            Spacer()

            Text("최근 알림")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 11 * scale))
                .foregroundColor(Color(red: 154 / 255, green: 154 / 255, blue: 161 / 255))
        }
        .padding(.horizontal, 16 * scale)
        .frame(width: 392 * scale, height: 44 * scale)
    }

    private func emptyState(scale: CGFloat) -> some View {
        VStack(spacing: 12 * scale) {
            Image(systemName: "bell.slash")
                .font(.system(size: 30 * scale, weight: .medium))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)

            Text("받은 알림이 없어요")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 15 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

            Text("새 알림이 도착하면 여기에서 확인할 수 있어요.")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct NotificationInboxView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationInboxView().previewDevice("iPhone 16")
    }
}
