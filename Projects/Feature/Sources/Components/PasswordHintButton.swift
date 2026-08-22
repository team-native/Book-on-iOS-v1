import SwiftUI

struct PasswordHintButton: View {
    @Binding var isShown: Bool
    var scale: CGFloat = 1

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.22)) {
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

            if isShown {
                PasswordHintBubble(scale: scale)
                .offset(y: 25 * scale)
                .allowsHitTesting(false)
                    .transition(
                        .opacity.combined(
                            with: .scale(scale: 0.96, anchor: .topTrailing)
                        )
                    )
                    .zIndex(100)
            }
        }
        .frame(width: 118 * scale, height: 32 * scale, alignment: .topTrailing)
        .contentShape(Rectangle())
    }
}

struct PasswordHintBubble: View {
    var scale: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("비밀번호 유의사항")
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 20 * scale))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("영문(대·소문자), 숫자")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 16 * scale))
                .foregroundColor(.black)
                .padding(.top, 18 * scale)

            Text("특수문자를 포함한 6~15자를 입력")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 16 * scale))
                .foregroundColor(.black)
                .padding(.top, 16 * scale)
        }
        .padding(.horizontal, 28 * scale)
        .padding(.vertical, 26 * scale)
        .frame(width: 331 * scale, height: 160 * scale, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24 * scale))
        .shadow(color: .black.opacity(0.12), radius: 14 * scale, x: 0, y: 6 * scale)
    }
}
