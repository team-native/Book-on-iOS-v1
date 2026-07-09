import SwiftUI

struct PasswordHintButton: View {
    var scale: CGFloat = 1

    @State private var isShown = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.16)) {
                isShown.toggle()
            }
        }) {
            HStack(spacing: 4 * scale) {
                Text("비밀번호 주의사항")
                    .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 10 * scale))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                Image(systemName: "info.circle")
                    .font(.system(size: 12 * scale))
            }
            .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
            .opacity(0.4)
            .frame(width: 118 * scale, height: 32 * scale, alignment: .trailing)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .overlay(alignment: .topTrailing) {
            if isShown {
                hintBubble
                    .offset(x: -20 * scale, y: 28 * scale)
                    .zIndex(10)
            }
        }
    }

    private var hintBubble: some View {
        VStack(alignment: .leading, spacing: 4 * scale) {
            Text("비밀번호 유의사항")
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 13 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

            Text("영문(대·소문자), 숫자\n특수문자를 포함한 6-15자를 입력")
                .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12 * scale)
        .frame(width: 184 * scale, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12 * scale)
        .shadow(color: .black.opacity(0.15), radius: 8 * scale, x: 0, y: 2 * scale)
    }
}
