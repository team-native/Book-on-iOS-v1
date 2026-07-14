import SwiftUI

struct BookSearchField: View {
    @Binding var text: String
    var width: CGFloat = 340
    var scale: CGFloat = 1
    var onSubmit: () -> Void = {}
    var onClear: (() -> Void)?
    var onSearch: () -> Void = {}
    var onActivate: (() -> Void)?
    var body: some View {
        HStack {
            TextField("도서 찾기", text: $text).font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale)).onSubmit(onSubmit)
            Spacer()
            if let onClear, !text.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13 * scale, weight: .medium))
                        .foregroundColor(Color(red: 174/255, green: 174/255, blue: 180/255))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("검색어 지우기")
            }
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13 * scale, weight: .bold))
                    .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("검색")
        }
        .padding(.horizontal, 12 * scale).frame(width: width * scale, height: 42 * scale)
        .background(Color.white).overlay(RoundedRectangle(cornerRadius: 16 * scale).stroke(Color(red: 140/255, green: 140/255, blue: 140/255), lineWidth: 0.4 * scale))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale)).shadow(color: .black.opacity(0.1), radius: 3 * scale, x: scale, y: scale)
        .overlay {
            if let onActivate {
                Button(action: onActivate) {
                    Color.clear
                        .contentShape(RoundedRectangle(cornerRadius: 16 * scale))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("도서 찾기")
                .accessibilityHint("검색 화면을 엽니다")
            }
        }
    }
}
