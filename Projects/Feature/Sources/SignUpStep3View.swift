import SwiftUI
import UIKit

struct SignUpStep3View: View {
    @Binding var info: SignUpAccountInfo
    let isLinking: Bool
    let linkError: String?
    let onLink: (String, String) -> Void
    let onNext: () -> Void

    @State private var isLinkFormPresented = false
    @State private var showsNoticeBanner = false
    @StateObject private var keyboard = KeyboardObserver()

    private var isLinkFormValid: Bool {
        !info.marathonId.isEmpty && !info.marathonPassword.isEmpty
    }

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor
                    .contentShape(Rectangle())
                    .onTapGesture { hideKeyboard() }

                SignUpProgressBar(currentStep: 3, scale: scale)
                    .frame(width: 333 * scale, alignment: .leading)
                    .offset(x: 30 * scale, y: 131 * scale)

                if isLinkFormPresented {
                    linkForm(scale: scale, screenHeight: geo.size.height)
                } else {
                    marathonChoice(scale: scale, screenWidth: geo.size.width)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .onAppear {
            showNoticeBannerWithDelay()
        }
        .onChange(of: info.isMarathonLinked) { _ in
            guard !isLinkFormPresented else { return }

            showsNoticeBanner = false
            showNoticeBannerWithDelay()
        }
    }

    private func marathonChoice(scale: CGFloat, screenWidth: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 24 * scale) {
                VStack(alignment: .leading, spacing: 8 * scale) {
                    Text("독서마라톤")
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                        .foregroundColor(.black)

                    Text("독서마라톤 계정을 연동하면\n읽은 책이 자동으로 기록돼요")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                        .lineSpacing(2 * scale)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SwitchRow(
                    title: "독서마라톤 이용하기",
                    subtitle: "교내 독서마라톤에 참여 중이라면 연동하세요",
                    isOn: $info.isMarathonLinked,
                    scale: scale
                )

                if showsNoticeBanner {
                    NoticeBanner(
                        text: info.isMarathonLinked
                            ? "연동하면 홈 · 마이페이지에서 진척도와 랭킹이 자동으로 표시돼요."
                            : "지금 연동하지 않아도 괜찮아요. 마이페이지에서 언제든 다시 연동할 수 있어요!",
                        tone: info.isMarathonLinked ? .highlighted : .neutral,
                        scale: scale
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeOut(duration: 0.62), value: showsNoticeBanner)
            .frame(width: 342 * scale, alignment: .leading)
            .offset(x: 25 * scale, y: 191 * scale)

            VStack(spacing: 16 * scale) {
                PrimaryButton(
                    title: info.isMarathonLinked ? "연동하고 가입완료" : "가입 완료",
                    scale: scale,
                    action: {
                        if info.isMarathonLinked {
                            isLinkFormPresented = true
                        } else {
                            onNext()
                        }
                    }
                )

                Button(action: {
                    info.isMarathonLinked = false
                    onNext()
                }) {
                    Text("나중에 할게요 · 건너뛰기")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                }
                .buttonStyle(.plain)
            }
            .frame(width: screenWidth, alignment: .center)
            .offset(y: 734 * scale)
        }
    }

    private func linkForm(scale: CGFloat, screenHeight: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 8 * scale) {
                Text("계정연동")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 28 * scale))
                    .foregroundColor(.black)

                Text("독서마라톤 아이디와 비밀번호를\n입력해 주세요")
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale))
                    .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    .lineSpacing(2 * scale)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .offset(x: 25 * scale, y: 191 * scale)

            VStack(alignment: .leading, spacing: 10 * scale) {
                AuthTextField(
                    icon: nil,
                    placeholder: "s20000@gsm.hs.kr",
                    text: $info.marathonId,
                    label: "독서마라톤 아이디",
                    fieldWidth: 342,
                    scale: scale
                )

                AuthTextField(
                    icon: nil,
                    placeholder: "비밀번호",
                    text: $info.marathonPassword,
                    label: "비밀번호",
                    isSecure: true,
                    fieldWidth: 342,
                    scale: scale
                )

                if let linkError {
                    InlineErrorText(message: linkError, scale: scale)
                }
            }
            .offset(x: 25 * scale, y: 296 * scale)

            KeyboardAvoidingBottomButton(
                screenHeight: screenHeight,
                contentBottomY: (734 + 52 + 16 + 17) * scale,
                keyboard: keyboard
            ) {
                VStack(spacing: 16 * scale) {
                    PrimaryButton(
                        title: isLinking ? "연동 중..." : "연동하고 가입완료",
                        scale: scale,
                        isEnabled: !isLinking,
                        action: {
                        hideKeyboard()
                        guard isLinkFormValid else { return }
                        onLink(
                            info.marathonId.trimmingCharacters(in: .whitespacesAndNewlines),
                            info.marathonPassword
                        )
                    })

                    Button(action: {
                        hideKeyboard()
                        guard !isLinking else { return }
                        info.isMarathonLinked = false
                        onNext()
                    }) {
                        Text("나중에 할게요 · 건너뛰기")
                            .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 14 * scale))
                            .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: FigmaDesign.size.width * scale, alignment: .center)
                .offset(y: 734 * scale)
            }
        }
    }

    private func showNoticeBannerWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.easeOut(duration: 0.62)) {
                showsNoticeBanner = true
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        keyboard.reset()
    }
}
