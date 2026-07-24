import SwiftUI
import Service

struct ProfileAvatar: View {
    var size: CGFloat = 30
    var scale: CGFloat = 1
    var imagePath: String?

    var body: some View {
        ZStack {
            Color(red: 226/255, green: 226/255, blue: 227/255)

            Image(systemName: "person.fill")
                .font(.system(size: size * 0.48 * scale))
                .foregroundColor(.white)

            if let url = profileImageURL {
                RemoteProfileImage(url: url)
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
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                Color.clear
            }
        }
        .task(id: url) {
            image = nil
            isLoading = true
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.timeoutInterval = 10

            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode,
                  let loadedImage = UIImage(data: data)
            else {
                image = nil
                isLoading = false
                return
            }
            image = loadedImage
            isLoading = false
        }
    }
}
