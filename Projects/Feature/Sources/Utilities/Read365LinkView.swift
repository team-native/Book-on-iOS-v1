import SwiftUI
import WebKit

struct Read365LinkView: View {
    let isSubmitting: Bool
    let serverError: String?
    let onBack: () -> Void
    let onLink: (String) -> Void

    @State private var webView: WKWebView?
    @State private var isAgreed = false
    @State private var localError: String?

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor.ignoresSafeArea()

                AppBackButton(scale: scale, action: onBack)
                    .frame(width: 40 * scale, height: 40 * scale)
                    .background(FeatureAsset.Color.background.swiftUIColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10 * scale)
                            .stroke(Color(red: 234/255, green: 234/255, blue: 236/255), lineWidth: 0.6 * scale)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10 * scale))
                    .offset(x: 25 * scale, y: 57 * scale)

                SignUpProgressBar(currentStep: 3, scale: scale)
                    .frame(width: 333 * scale, alignment: .leading)
                    .offset(x: 30 * scale, y: 131 * scale)

                VStack(alignment: .leading, spacing: 8 * scale) {
                    Text("계정연동")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 28 * scale))
                        .foregroundColor(.black)
                    Text("read365 간편로그인을 진행해 주세요")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                        .lineSpacing(3 * scale)
                }
                .offset(x: 25 * scale, y: 191 * scale)

                VStack(alignment: .leading, spacing: 12 * scale) {
                    Read365WebView(webView: $webView)
                        .frame(width: 342 * scale, height: 360 * scale)
                        .clipShape(RoundedRectangle(cornerRadius: 14 * scale))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14 * scale)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        }

                    Button {
                        isAgreed.toggle()
                        localError = nil
                    } label: {
                        HStack(alignment: .top, spacing: 10 * scale) {
                            Image(systemName: isAgreed ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isAgreed ? FeatureAsset.Color.buttonColor.swiftUIColor : .secondary)
                            Text("독서마라톤 계정 연동을 위한 ")
                                .foregroundColor(Color(red: 159/255, green: 159/255, blue: 164/255))
                            + Text("개인정보 제3자 제공")
                                .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                            + Text("에\n동의합니다.")
                                .foregroundColor(Color(red: 159/255, green: 159/255, blue: 164/255))
                        }
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    }
                    .buttonStyle(.plain)

                    if let message = localError ?? serverError {
                        InlineErrorText(message: message, scale: scale)
                            .lineLimit(2)
                            .frame(width: 342 * scale, alignment: .leading)
                    }
                }
                .offset(x: 25 * scale, y: 296 * scale)

                PrimaryButton(
                    title: isSubmitting ? "연동 중..." : "로그인 완료 · 연동하기",
                    scale: scale,
                    isEnabled: !isSubmitting,
                    action: submit
                )
                .offset(x: 47 * scale, y: 734 * scale)
            }
        }
        .ignoresSafeArea()
    }

    private func submit() {
        guard let webView else {
            localError = "로그인 화면을 불러오는 중입니다. 잠시 후 다시 시도해주세요."
            return
        }
        guard isAgreed else {
            localError = "개인정보 제3자 제공에 동의해주세요."
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
