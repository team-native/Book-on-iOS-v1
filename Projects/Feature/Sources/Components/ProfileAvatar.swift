import SwiftUI

struct ProfileAvatar: View {
    var size: CGFloat = 30
    var scale: CGFloat = 1
    var body: some View {
        Image(systemName: "person.fill")
            .font(.system(size: size * 0.48 * scale))
            .foregroundColor(.white)
            .frame(width: size * scale, height: size * scale)
            .background(Color(red: 226/255, green: 226/255, blue: 227/255))
            .clipShape(Circle())
    }
}
