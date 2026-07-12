import SwiftUI

struct NavigationMenuRow: View {
    let title: String
    var isDestructive = false
    var scale: CGFloat = 1
    let action: () -> Void
    var body: some View {
        Button(action: action) { HStack {
            Text(title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 15 * scale)).foregroundColor(isDestructive ? Color(red: 182/255, green: 0, blue: 0) : .black)
            Spacer()
            if !isDestructive { Image(systemName: "chevron.right").font(.system(size: 14 * scale, weight: .medium)).foregroundColor(Color(red: 199/255, green: 199/255, blue: 204/255)) }
        }.frame(height: 50 * scale) }.buttonStyle(.plain)
    }
}
