import SwiftUI

struct BookSearchField: View {
    @Binding var text: String
    var width: CGFloat = 340
    var scale: CGFloat = 1
    var onSubmit: () -> Void = {}
    var body: some View {
        HStack {
            TextField("도서 찾기", text: $text).font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale)).onSubmit(onSubmit)
            Spacer()
            Image(systemName: "magnifyingglass").font(.system(size: 13 * scale, weight: .medium)).foregroundColor(Color(red: 183/255, green: 183/255, blue: 183/255))
        }
        .padding(.horizontal, 12 * scale).frame(width: width * scale, height: 42 * scale)
        .background(Color.white).overlay(RoundedRectangle(cornerRadius: 16 * scale).stroke(Color(red: 140/255, green: 140/255, blue: 140/255), lineWidth: 0.4 * scale))
        .clipShape(RoundedRectangle(cornerRadius: 16 * scale)).shadow(color: .black.opacity(0.1), radius: 3 * scale, x: scale, y: scale)
    }
}
