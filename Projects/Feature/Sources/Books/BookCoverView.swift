import SwiftUI

struct BookCoverView: View {
    let urlString: String?
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = 8

    var body: some View {
        AsyncImage(url: urlString.flatMap(URL.init(string:))) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(red: 241/255, green: 241/255, blue: 244/255))
                .overlay(Image(systemName: "book.closed").foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor))
        }
        .frame(width: width, height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
