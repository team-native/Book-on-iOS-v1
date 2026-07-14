import SwiftUI

struct PasswordHintButton: View {
    @Binding var isShown: Bool
    var scale: CGFloat = 1

    var body: some View {
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
        .contentShape(Rectangle())
    }
}

struct PasswordHintBubble: View {
    var scale: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("비밀번호 유의사항")
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                .foregroundColor(.black)
                .frame(width: 136 * scale, height: 20 * scale, alignment: .leading)

            Text("영문(대·소문자), 숫자")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 10 * scale))
                .foregroundColor(.black)
                .frame(width: 136 * scale, height: 20 * scale, alignment: .leading)

            Text("특수문자를 포함한 6~15자를 입력")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 10 * scale))
                .foregroundColor(.black)
                .frame(width: 136 * scale, height: 20 * scale, alignment: .leading)
        }
        .padding(.horizontal, 12 * scale)
        .padding(.vertical, 10 * scale)
        .frame(width: 160 * scale, height: 80 * scale, alignment: .topLeading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12 * scale))
        .shadow(color: .black.opacity(0.12), radius: 7 * scale, x: 0, y: 2 * scale)
    }
}
