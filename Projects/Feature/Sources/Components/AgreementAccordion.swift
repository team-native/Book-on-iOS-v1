import SwiftUI

struct AgreementAccordion: View {
    @Binding var isExpanded: Bool
    @Binding var isAgreed: Bool
    var scale: CGFloat = 1

    @State private var hasReachedEnd = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if isExpanded {
                detailsScrollView
                    .padding(.top, 12 * scale)
            }

            checkboxRow
                .padding(.top, 12 * scale)
        }
        .padding(16 * scale)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12 * scale)
                .stroke(FeatureAsset.Color.borderLight.swiftUIColor.opacity(0.5), lineWidth: 0.8 * scale)
        )
        .cornerRadius(12 * scale)
    }

    private var header: some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
            HStack {
                Text("개인정보 수집 및 이용 안내")
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor.opacity(0.78))

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 12 * scale, weight: .semibold))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor.opacity(0.78))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
        }
        .buttonStyle(.plain)
    }

    private var detailsScrollView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10 * scale) {
                detailSection(title: "1. 수집 항목", body: "이름, 학교 이메일 주소, 비밀번호, 학과 및 성별 정보")
                detailSection(title: "2. 수집 목적", body: "• 회원 식별 및 계정 관리\n• 학교 인증 기반 서비스 제공\n• 공지사항 전달 및 이용 문의 대응")
                detailSection(title: "3. 보유 및 이용 기간", body: "회원 탈퇴 또는 서비스 이용 목적 달성 시까지 보관하며, 관계 법령에 따라 보존이 필요한 항목은 해당 기간 동안 보관합니다.")
                detailSection(title: "4. 이용약관 안내", body: "• 서버 점검이나 업데이트 시 서비스가 일시 중단될 수 있습니다.\n• 부정 이용이 확인될 경우 서비스 이용이 제한될 수 있습니다.")
                detailSection(title: "5. 개인정보 처리 안내", body: "수집된 개인정보는 동의한 목적 외로 이용되지 않으며, 안전한 서비스 운영을 위해 접근 권한을 최소화하여 관리합니다.")

                Text("이용자는 개인정보 수집 및 이용에 대한 동의를 거부할 권리가 있으며, 동의를 거부할 경우 회원가입이 제한될 수 있습니다.")
                    .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 11 * scale))
                    .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
                    .padding(10 * scale)
                    .background(FeatureAsset.Color.background.swiftUIColor)
                    .cornerRadius(8 * scale)

                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        hasReachedEnd = true
                        isAgreed = true
                    }
            }
        }
        .frame(height: 180 * scale)
    }

    private func detailSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 2 * scale) {
            Text(title)
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor.opacity(0.82))

            Text(body)
                .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale))
                .foregroundColor(FeatureAsset.Color.textDescription.swiftUIColor)
        }
    }

    private var checkboxRow: some View {
        Button(action: { isAgreed.toggle() }) {
            HStack(spacing: 8 * scale) {
                ZStack {
                    Circle()
                        .fill(isAgreed ? FeatureAsset.Color.buttonColor.swiftUIColor : Color.white)
                        .overlay(
                            Circle().stroke(
                                isAgreed
                                    ? FeatureAsset.Color.buttonColor.swiftUIColor
                                    : FeatureAsset.Color.borderLight.swiftUIColor,
                                lineWidth: 1
                            )
                        )
                        .frame(width: 16 * scale, height: 16 * scale)

                    if isAgreed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8 * scale, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Text("개인정보 수집 및 이용에 동의합니다 (필수)")
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
            }
            .opacity(hasReachedEnd ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!hasReachedEnd)
    }
}
