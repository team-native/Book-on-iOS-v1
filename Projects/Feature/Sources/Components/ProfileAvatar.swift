import SwiftUI
import Service

struct ProfileAvatar: View {
    var size: CGFloat = 30
    var scale: CGFloat = 1
    var imagePath: String?

    var body: some View {
        ZStack {
            Color(red: 226/255, green: 226/255, blue: 227/255)

            if let url = profileImageURL {
                RemoteProfileImage(url: url)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.48 * scale))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size * scale, height: size * scale)
        .clipShape(Circle())
        .accessibilityLabel("프로필 사진")
    }

    private var profileImageURL: URL? {
        guard let imagePath, !imagePath.isEmpty else { return nil }
        if let absoluteURL = URL(string: imagePath), absoluteURL.scheme != nil {
            return absoluteURL
        }
        return URL(string: imagePath, relativeTo: APIConfiguration.baseURL)?.absoluteURL
    }
}

private struct RemoteProfileImage: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .task(id: url) {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode,
                  let loadedImage = UIImage(data: data)
            else {
                image = nil
                return
            }
            image = loadedImage
        }
    }
}
