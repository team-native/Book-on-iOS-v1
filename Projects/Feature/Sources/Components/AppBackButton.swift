import SwiftUI

struct AppBackButton: View {
    var scale: CGFloat = 1
    let action: () -> Void
    var body: some View {
        Button(action: action) { Image(systemName: "chevron.left").font(.system(size: 19 * scale, weight: .semibold)).foregroundColor(.black).frame(width: 40 * scale, height: 40 * scale) }.buttonStyle(.plain)
    }
}
