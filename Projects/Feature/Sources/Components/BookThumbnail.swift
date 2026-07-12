import SwiftUI

struct BookThumbnail: View {
    var width: CGFloat = 94
    var height: CGFloat = 160
    var scale: CGFloat = 1
    let action: () -> Void
    var body: some View { Button(action: action) { Color.clear.frame(width: width * scale, height: height * scale).contentShape(Rectangle()) }.buttonStyle(.plain) }
}
