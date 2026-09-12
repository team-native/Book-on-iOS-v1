import SwiftUI
import WebKit

struct Read365LinkView: View {
    let isSubmitting: Bool
    let serverError: String?
    let onBack: () -> Void
    let onLink: (String) -> Void

    @State private var webView: WKWebView?
    @State private var localError: String?

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width

            ZStack(alignment: .topLeading) {
                Color(red: 246 / 255, green: 249 / 255, blue: 242 / 255)
                    .ignoresSafeArea()

                AppBackButton(scale: scale, action: onBack)
                    .frame(width: 40 * scale, height: 40 * scale)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 8 * scale, y: 3 * scale)
                    .offset(x: 25 * scale, y: 57 * scale)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8 * scale) {
                        FeatureAsset.Image.readingMarathonLogo.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24 * scale, height: 24 * scale)
                            .padding(8 * scale)
                            .background(FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 12 * scale))
                        Text("2026 독서마라톤")
                            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 13 * scale))
                            .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                    }

                    Text("독서마라톤 계정 연동")
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 26 * scale))
                        .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                        .padding(.top, 14 * scale)

                    Text("아래 웹 화면에서 로그인한 뒤\n연동하기 버튼을 눌러주세요.")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                        .lineSpacing(3 * scale)
                        .padding(.top, 8 * scale)

                    VStack(alignment: .leading, spacing: 12 * scale) {
                        Text("독서마라톤 로그인")
                            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 13 * scale))
                            .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

                        Read365WebView(webView: $webView)
                            .frame(height: 410 * scale)
                            .clipShape(RoundedRectangle(cornerRadius: 16 * scale))
                    }
                    .padding(14 * scale)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20 * scale))
                    .shadow(color: .black.opacity(0.08), radius: 16 * scale, y: 6 * scale)
                    .padding(.top, 24 * scale)

                    if let message = localError ?? serverError {
                        InlineErrorText(message: message, scale: scale)
                            .lineLimit(2)
                            .padding(.top, 10 * scale)
                    }

                    Spacer(minLength: 16 * scale)

                    PrimaryButton(
                        title: isSubmitting ? "연동 중..." : "로그인 완료 · 연동하기",
                        scale: scale,
                        isEnabled: !isSubmitting,
                        action: submit
                    )
                }
                .padding(.horizontal, 25 * scale)
                .padding(.top, 120 * scale)
                .padding(.bottom, 28 * scale)
            }
        }
        .ignoresSafeArea()
    }

    private func submit() {
        guard let webView else {
            localError = "로그인 화면을 불러오는 중입니다. 잠시 후 다시 시도해주세요."
            return
        }
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            let cookieHeader = cookies
                .filter { cookie in
                    let domain = cookie.domain.lowercased()
                    return domain.contains("read365.edunet.net") || domain == ".edunet.net"
                }
                .map { "\($0.name)=\($0.value)" }
                .joined(separator: "; ")

            guard !cookieHeader.isEmpty else {
                DispatchQueue.main.async {
                    localError = "read365 로그인 Cookie를 찾지 못했어요. 먼저 웹에서 로그인을 완료해주세요."
                }
                return
            }

            DispatchQueue.main.async {
                onLink(cookieHeader)
            }
        }
    }
}

private struct Read365WebView: UIViewRepresentable {
    @Binding var webView: WKWebView?

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true

        if let url = URL(string: "https://read365.edunet.net") {
            webView.load(URLRequest(url: url))
        }

        DispatchQueue.main.async {
            self.webView = webView
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
