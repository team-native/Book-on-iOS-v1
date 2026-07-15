import SwiftUI

public struct SignUpEntryView: View {
    @State private var currentStep: SignUpStep = .schoolInfo
    @State private var progressStep = 1
    @State private var emailPrefix = ""
    @State private var name = ""
    @State private var selectedGender: Gender?
    @State private var selectedDepartment: Department?
    @State private var emailError: String?
    @State private var nameError: String?
    @State private var genderError: String?
    @State private var departmentError: String?
    @State private var isReadingMarathonLinked = false
    @State private var readingMarathonSubstep: ReadingMarathonSubstep = .intro
    @State private var isVerificationSentAlertPresented = false
    @State private var isPasswordHintShown = false
    @StateObject private var keyboard = KeyboardObserver()

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / FigmaDesign.size.width
            let buttonHeight = 52 * scale
            let buttonY = KeyboardButtonLayout.bottomY(
                containerHeight: geo.size.height,
                buttonHeight: buttonHeight,
                scale: scale,
                keyboardHeight: keyboard.height
            )

            ZStack(alignment: .topLeading) {
                FeatureAsset.Color.background.swiftUIColor
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { UIApplication.hideKeyboard() }

                if currentStep == .schoolInfo {
                    StepHeader(step: 1, filledStep: progressStep, scale: scale)
                        .offset(x: 31 * scale, y: 18 * scale)

                    Text("학교 정보")
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 28 * scale))
                        .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                        .offset(x: 31 * scale, y: 78 * scale)

                    Text("학교 계정으로 간편하게 가입하세요!")
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                        .offset(x: 31 * scale, y: 117 * scale)

                    VStack(alignment: .leading, spacing: 14 * scale) {
                        SignUpFieldTitle("학교 이메일", scale: scale)
                        AuthTextField(
                            icon: "envelope",
                            placeholder: "이메일 주소",
                            text: $emailPrefix,
                            suffix: "@gsm.hs.kr",
                            errorMessage: emailError,
                            showsInlineCaption: true,
                            keyboardType: .asciiCapable,
                            maxLength: 6,
                            allowsSchoolEmailPrefix: true,
                            fieldWidth: 331,
                            horizontalPadding: 18,
                            scale: scale
                        )

                        SignUpFieldTitle("이름", scale: scale)
                            .padding(.top, 10 * scale)
                        AuthTextField(
                            icon: "person",
                            placeholder: "이름",
                            text: $name,
                            errorMessage: nameError,
                            showsInlineCaption: true,
                            fieldWidth: 331,
                            horizontalPadding: 18,
                            scale: scale
                        )

                        SignUpFieldTitle("성별", scale: scale)
                            .padding(.top, 10 * scale)
                        HStack(spacing: 22 * scale) {
                            GenderSelectButton(title: "남자", isSelected: selectedGender == .male, scale: scale) {
                                UIApplication.hideKeyboard()

                                withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                                    selectedGender = .male
                                    genderError = nil
                                }
                            }

                            GenderSelectButton(title: "여자", isSelected: selectedGender == .female, scale: scale) {
                                UIApplication.hideKeyboard()

                                withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                                    selectedGender = .female
                                    genderError = nil
                                }
                            }
                        }

                        if let genderError {
                            InlineErrorText(message: genderError, scale: scale)
                        }

                        SignUpFieldTitle("학과", scale: scale)
                            .padding(.top, 10 * scale)
                        DepartmentPickerField(
                            selectedDepartment: $selectedDepartment,
                            scale: scale
                        )

                        if let departmentError {
                            InlineErrorText(message: departmentError, scale: scale)
                        }
                    }
                    .offset(x: 31 * scale, y: 154 * scale)

                    PrimaryButton(title: "다음", scale: scale) {
                        submitSchoolInfo()
                    }
                        .offset(x: 47 * scale, y: buttonY)
                        .animation(.easeOut(duration: 0.22), value: keyboard.height)
                } else if currentStep == .verificationCode {
                    VerificationCodeStepView(
                        email: "\(emailPrefix)@gsm.hs.kr",
                        filledStep: progressStep,
                        scale: scale,
                        buttonY: buttonY,
                        onVerified: {
                            move(to: .accountInfo)
                        }
                    )
                } else if currentStep == .accountInfo {
                    AccountInfoStepView(
                        filledStep: progressStep,
                        scale: scale,
                        buttonY: buttonY,
                        isPasswordHintShown: $isPasswordHintShown,
                        onCompleted: {
                            move(to: .readingMarathon)
                        }
                    )
                    .offset(x: 31 * scale, y: 18 * scale)
                } else if currentStep == .readingMarathon {
                    ReadingMarathonStepView(
                        email: "\(emailPrefix)@gsm.hs.kr",
                        filledStep: progressStep,
                        scale: scale,
                        buttonY: buttonY,
                        substep: $readingMarathonSubstep,
                        onCompleted: { isLinked in
                            isReadingMarathonLinked = isLinked
                            move(to: .complete)
                        }
                    )
                    .offset(x: 31 * scale, y: 18 * scale)
                } else {
                    SignUpCompleteStepView(
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        isReadingMarathonLinked: isReadingMarathonLinked,
                        scale: scale,
                        buttonY: buttonY
                    )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: emailPrefix) { _ in
            emailError = nil
        }
        .onChange(of: name) { _ in
            nameError = nil
        }
        .onChange(of: selectedDepartment) { _ in
            departmentError = nil
        }
        .navigationBarBackButtonHidden(currentStep != .schoolInfo)
        .toolbar {
            if currentStep != .schoolInfo && currentStep != .complete {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        goBackStep()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
        .toolbar(currentStep == .complete ? .hidden : .automatic, for: .navigationBar)
        .alert("인증번호를 발송했어요", isPresented: $isVerificationSentAlertPresented) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("이메일을 확인해보세요")
        }
    }

    private func submitSchoolInfo() {
        UIApplication.hideKeyboard()
        clearErrors()

        let trimmedEmail = emailPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            emailError = "이메일 주소를 입력해주세요"
            return
        }

        if trimmedEmail.range(of: #"^s\d{5}$"#, options: .regularExpression) == nil {
            emailError = "올바른 이메일 형식이 아니에요"
            return
        }

        if trimmedName.isEmpty {
            nameError = "이름을 입력해주세요"
            return
        }

        if selectedGender == nil {
            genderError = "성별을 선택해주세요"
            return
        }

        if selectedDepartment == nil {
            departmentError = "학과를 선택해주세요"
            return
        }

        move(to: .verificationCode)
        isVerificationSentAlertPresented = true
    }

    private func goBackStep() {
        UIApplication.hideKeyboard()

        switch currentStep {
        case .schoolInfo:
            break
        case .verificationCode:
            move(to: .schoolInfo)
        case .accountInfo:
            move(to: .verificationCode)
        case .readingMarathon:
            if readingMarathonSubstep == .accountLink {
                withAnimation(.easeOut(duration: 0.2)) {
                    readingMarathonSubstep = .intro
                }
            } else {
                move(to: .accountInfo)
            }
        case .complete:
            move(to: .readingMarathon)
        }
    }

    private func move(to nextStep: SignUpStep) {
        let previousVisualStep = currentStep.visualStep
        currentStep = nextStep
        if nextStep == .readingMarathon {
            readingMarathonSubstep = .intro
        }

        guard nextStep.visualStep != previousVisualStep else { return }

        withAnimation(.easeOut(duration: 0.38)) {
            progressStep = nextStep.visualStep
        }
    }

    private func clearErrors() {
        emailError = nil
        nameError = nil
        genderError = nil
        departmentError = nil
    }
}

private enum SignUpStep {
    case schoolInfo
    case verificationCode
    case accountInfo
    case readingMarathon
    case complete

    var visualStep: Int {
        switch self {
        case .schoolInfo, .verificationCode:
            return 1
        case .accountInfo:
            return 2
        case .readingMarathon, .complete:
            return 3
        }
    }
}

private enum ReadingMarathonSubstep {
    case intro
    case accountLink
}

private enum Gender {
    case male
    case female
}

private enum Department: String, CaseIterable, Identifiable {
    case software = "SW과"
    case iot = "iOT과"
    case ai = "AI과"

    var id: String { rawValue }
}

private struct StepHeader: View {
    var step: Int = 1
    var filledStep: Int
    let scale: CGFloat

    var body: some View {
        let segmentWidth = 104 * scale

        VStack(alignment: .leading, spacing: 8 * scale) {
            HStack(spacing: 10 * scale) {
                ForEach(1...3, id: \.self) { index in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 232 / 255, green: 232 / 255, blue: 235 / 255))

                        Capsule()
                            .fill(FeatureAsset.Color.buttonColor.swiftUIColor)
                            .frame(width: index <= filledStep ? segmentWidth : 0)
                    }
                    .frame(width: segmentWidth, height: 4 * scale)
                    .clipped()
                }
            }
            .frame(width: 332 * scale, height: 4 * scale)

            Text("STEP \(step) / 3")
                .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
        }
    }
}

private struct SignUpFieldTitle: View {
    let title: String
    let scale: CGFloat

    init(_ title: String, scale: CGFloat) {
        self.title = title
        self.scale = scale
    }

    var body: some View {
        Text(title)
            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
            .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
    }
}

private struct GenderSelectButton: View {
    let title: String
    let isSelected: Bool
    let scale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 14 * scale))
                .foregroundColor(isSelected ? FeatureAsset.Color.buttonColor.swiftUIColor : FeatureAsset.Color.textPlaceholder.swiftUIColor)
                .frame(width: 154 * scale, height: 52 * scale)
                .background(Color.white)
                .cornerRadius(16 * scale)
                .overlay(
                    RoundedRectangle(cornerRadius: 16 * scale)
                        .stroke(isSelected ? FeatureAsset.Color.buttonColor.swiftUIColor : .clear, lineWidth: 1 * scale)
                )
                .shadow(color: .black.opacity(isSelected ? 0.18 : 0.12), radius: 6 * scale, x: 1 * scale, y: 1 * scale)
                .scaleEffect(isSelected ? 1.02 : 1)
        }
        .buttonStyle(.plain)
    }
}

private struct DepartmentPickerField: View {
    @Binding var selectedDepartment: Department?
    let scale: CGFloat

    var body: some View {
        Menu {
            ForEach(Department.allCases) { department in
                Button(department.rawValue) {
                    UIApplication.hideKeyboard()
                    selectedDepartment = department
                }
            }
        } label: {
            HStack(spacing: 0) {
                Text(selectedDepartment?.rawValue ?? "학과")
                    .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 14 * scale))
                    .foregroundColor(
                        selectedDepartment == nil
                        ? FeatureAsset.Color.textPlaceholder.swiftUIColor
                        : FeatureAsset.Color.textPrimary.swiftUIColor
                    )

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 13 * scale, weight: .semibold))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
            }
            .padding(.horizontal, 20 * scale)
            .frame(width: 331 * scale, height: 52 * scale)
            .background(Color.white)
            .cornerRadius(16 * scale)
            .shadow(color: .black.opacity(0.15), radius: 6 * scale, x: 1 * scale, y: 1 * scale)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.hideKeyboard()
            }
        )
    }
}

private struct VerificationCodeStepView: View {
    let email: String
    let filledStep: Int
    let scale: CGFloat
    let buttonY: CGFloat
    let onVerified: () -> Void

    @State private var code = ""
    @State private var codeError: String?
    @State private var remainingSeconds = 292
    @FocusState private var isCodeFocused: Bool

    var body: some View {
        Group {
            StepHeader(step: 1, filledStep: filledStep, scale: scale)
                .offset(x: 31 * scale, y: 18 * scale)

            Text("인증번호 입력")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 28 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                .offset(x: 31 * scale, y: 78 * scale)

            VStack(alignment: .leading, spacing: 4 * scale) {
                Text(email)
                    .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor.opacity(0.82))
                + Text(" 으로 보낸")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)

                Text("6자리 코드를 입력해 주세요")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                    .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
            }
            .offset(x: 31 * scale, y: 119 * scale)

            ZStack(alignment: .leading) {
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .focused($isCodeFocused)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .onChange(of: code) { newValue in
                        code = String(newValue.filter(\.isNumber).prefix(6))
                        codeError = nil
                    }

                HStack(spacing: 16 * scale) {
                    ForEach(0..<6, id: \.self) { index in
                        VStack(spacing: 8 * scale) {
                            Text(character(at: index))
                                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 28 * scale))
                                .foregroundColor(index == code.count ? FeatureAsset.Color.buttonColor.swiftUIColor : FeatureAsset.Color.textPrimary.swiftUIColor)
                                .frame(width: 28 * scale, height: 34 * scale)

                            Rectangle()
                                .fill(index == code.count ? FeatureAsset.Color.buttonColor.swiftUIColor : FeatureAsset.Color.textPrimary.swiftUIColor)
                                .frame(width: 30 * scale, height: 2 * scale)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isCodeFocused = true
            }
            .offset(x: 31 * scale, y: 188 * scale)

            HStack(spacing: 4 * scale) {
                Image(systemName: "clock")
                    .font(.system(size: 12 * scale, weight: .regular))
                Text("\(remainingTimeText) 후 만료")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 12 * scale))
            }
            .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
            .offset(x: 31 * scale, y: 258 * scale)

            if let codeError {
                InlineErrorText(message: codeError, scale: scale)
                    .offset(x: 31 * scale, y: 284 * scale)
            }

            PrimaryButton(title: "인증하기", scale: scale) {
                UIApplication.hideKeyboard()

                guard code.count == 6, Set(code) == ["0"] else {
                    codeError = "인증번호를 다시 확인해주세요"
                    return
                }

                onVerified()
            }
            .offset(x: 47 * scale, y: buttonY)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard remainingSeconds > 0 else { return }
            remainingSeconds -= 1
        }
    }

    private func character(at index: Int) -> String {
        guard index < code.count else { return "" }
        return String(Array(code)[index])
    }

    private var remainingTimeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct AccountInfoStepView: View {
    let filledStep: Int
    let scale: CGFloat
    let buttonY: CGFloat
    @Binding var isPasswordHintShown: Bool
    let onCompleted: () -> Void

    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var passwordError: String?
    @State private var passwordConfirmError: String?
    @State private var agreementError: String?
    @State private var isAgreed = false
    @State private var isAgreementExpanded = false
    @State private var hasReadAgreement = false

    var body: some View {
        Group {
            StepHeader(step: 2, filledStep: filledStep, scale: scale)

            PasswordHintButton(isShown: $isPasswordHintShown, scale: scale)
                .frame(width: 118 * scale, height: 32 * scale, alignment: .trailing)
                .offset(x: 219 * scale, y: 56 * scale)
                .zIndex(101)

            Text("계정 정보")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 28 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                .offset(y: 60 * scale)

            Text("비밀번호를 설정해주세요")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                .offset(y: 99 * scale)

            VStack(alignment: .leading, spacing: 14 * scale) {
                SignUpFieldTitle("비밀번호", scale: scale)
                AuthTextField(
                    icon: "lock",
                    placeholder: "비밀번호",
                    text: $password,
                    isSecure: true,
                    errorMessage: passwordError,
                    showsInlineCaption: true,
                    fieldWidth: 331,
                    horizontalPadding: 18,
                    scale: scale
                )

                SignUpFieldTitle("확인", scale: scale)
                    .padding(.top, 10 * scale)
                AuthTextField(
                    icon: "lock",
                    placeholder: "비밀번호 확인",
                    text: $passwordConfirm,
                    isSecure: true,
                    errorMessage: passwordConfirmError,
                    showsInlineCaption: true,
                    fieldWidth: 331,
                    horizontalPadding: 18,
                    scale: scale
                )

                AgreementBox(
                    isExpanded: $isAgreementExpanded,
                    isAgreed: $isAgreed,
                    hasReadAgreement: $hasReadAgreement,
                    scale: scale
                )
                .padding(.top, 10 * scale)

                if let agreementError {
                    InlineErrorText(message: agreementError, scale: scale)
                }
            }
            .offset(y: 142 * scale)

            PrimaryButton(title: "가입 완료", scale: scale) {
                submitAccountInfo()
            }
            .offset(x: 16 * scale, y: buttonY - (18 * scale))
        }
        .onChange(of: password) { _ in
            passwordError = nil
            passwordConfirmError = nil
        }
        .onChange(of: passwordConfirm) { _ in
            passwordConfirmError = nil
        }
        .onChange(of: isAgreed) { _ in
            agreementError = nil
        }
    }

    private func submitAccountInfo() {
        UIApplication.hideKeyboard()
        passwordError = nil
        passwordConfirmError = nil
        agreementError = nil

        if password.isEmpty {
            passwordError = "비밀번호를 입력해주세요"
            return
        }

        if passwordConfirm.isEmpty {
            passwordConfirmError = "비밀번호 확인을 입력해주세요"
            return
        }

        if password != passwordConfirm {
            passwordConfirmError = "비밀번호를 다시 확인해주세요"
            return
        }

        if !isAgreed {
            agreementError = "개인정보 수집 및 이용에 동의해주세요"
            return
        }

        onCompleted()
    }
}

private struct ReadingMarathonStepView: View {
    let email: String
    let filledStep: Int
    let scale: CGFloat
    let buttonY: CGFloat
    @Binding var substep: ReadingMarathonSubstep
    let onCompleted: (Bool) -> Void

    @State private var isInfoVisible = false
    @State private var isLinkRequested = false
    @State private var isThirdPartyAgreed = false
    @State private var marathonPassword = ""
    @State private var marathonPasswordError: String?
    @State private var thirdPartyError: String?

    private var isLinking: Bool {
        substep == .accountLink
    }

    private var linkToggle: Binding<Bool> {
        Binding(
            get: { isLinkRequested },
            set: { isOn in
                UIApplication.hideKeyboard()

                withAnimation(.easeOut(duration: 0.18)) {
                    isLinkRequested = isOn
                }
                playInfoIntroAnimation(delay: 0.08)
            }
        )
    }

    var body: some View {
        Group {
            StepHeader(step: 3, filledStep: filledStep, scale: scale)

            if isLinking {
                accountLinkContent
                    .transition(.opacity)
            } else {
                introContent
                    .transition(.opacity)
            }
        }
        .onAppear {
            playInfoIntroAnimation(delay: 0.28)
        }
        .onChange(of: marathonPassword) { _ in
            marathonPasswordError = nil
        }
        .onChange(of: isThirdPartyAgreed) { _ in
            thirdPartyError = nil
        }
        .animation(.easeOut(duration: 0.22), value: substep)
    }

    private var introContent: some View {
        Group {
            Text("독서마라톤")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 28 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                .offset(y: 60 * scale)

            Text("독서마라톤 계정을 연동하면\n읽은 책이 자동으로 기록돼요")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                .lineSpacing(4 * scale)
                .offset(y: 101 * scale)

            ReadingMarathonUseCard(isLinked: isLinkRequested, toggle: linkToggle, scale: scale)
                .offset(y: 150 * scale)
                .zIndex(3)

            if isInfoVisible {
                ReadingMarathonInfoBox(isLinked: isLinkRequested, scale: scale)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .offset(y: 252 * scale)
                    .zIndex(1)
            }

            PrimaryButton(title: isLinkRequested ? "연동하기" : "가입완료", scale: scale) {
                UIApplication.hideKeyboard()

                if isLinkRequested {
                    withAnimation(.easeOut(duration: 0.22)) {
                        substep = .accountLink
                    }
                } else {
                    onCompleted(false)
                }
            }
            .offset(x: 16 * scale, y: buttonY - (18 * scale))
        }
    }

    private var accountLinkContent: some View {
        Group {
            Text("계정연동")
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 28 * scale))
                .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                .offset(y: 60 * scale)

            Text("독서마라톤 아이디와 비밀번호를\n입력해 주세요")
                .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 14 * scale))
                .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                .lineSpacing(4 * scale)
                .offset(y: 101 * scale)

            VStack(alignment: .leading, spacing: 14 * scale) {
                SignUpFieldTitle("독서마라톤 아이디", scale: scale)
                MarathonReadOnlyEmailField(email: email, scale: scale)

                SignUpFieldTitle("비밀번호", scale: scale)
                    .padding(.top, 8 * scale)
                AuthTextField(
                    icon: "lock",
                    placeholder: "비밀번호",
                    text: $marathonPassword,
                    isSecure: true,
                    errorMessage: marathonPasswordError,
                    showsInlineCaption: true,
                    fieldWidth: 331,
                    horizontalPadding: 18,
                    scale: scale
                )

                ThirdPartyAgreementView(
                    isAgreed: $isThirdPartyAgreed,
                    scale: scale
                )
                .padding(.top, 2 * scale)

                if let thirdPartyError {
                    InlineErrorText(message: thirdPartyError, scale: scale)
                }

                SocialLoginButtons(scale: scale)
                    .padding(.top, 18 * scale)
            }
            .offset(y: 150 * scale)

            PrimaryButton(title: "연동하고 가입완료", scale: scale) {
                submitAccountLink()
            }
            .offset(x: 16 * scale, y: buttonY - (18 * scale))
        }
    }

    private func submitAccountLink() {
        UIApplication.hideKeyboard()
        marathonPasswordError = nil
        thirdPartyError = nil

        if marathonPassword.isEmpty {
            marathonPasswordError = "비밀번호를 입력해주세요"
            return
        }

        if !isThirdPartyAgreed {
            thirdPartyError = "개인정보 제3자 제공에 동의해주세요"
            return
        }

        onCompleted(true)
    }

    private func playInfoIntroAnimation(delay: Double) {
        isInfoVisible = false

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeOut(duration: 0.46)) {
                isInfoVisible = true
            }
        }
    }
}

private struct ReadingMarathonUseCard: View {
    let isLinked: Bool
    let toggle: Binding<Bool>
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 14 * scale) {
            ReadingMarathonLogoMark(isLinked: isLinked, scale: scale)

            VStack(alignment: .leading, spacing: 4 * scale) {
                Text("독서마라톤\n이용하기")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 15 * scale))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                    .lineSpacing(2 * scale)

                Text("교내 독서마라톤에 참여 중이라면 연동\n하세요")
                    .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                    .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                    .lineSpacing(2 * scale)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Toggle("", isOn: toggle)
                .labelsHidden()
                .tint(FeatureAsset.Color.buttonColor.swiftUIColor)
                .scaleEffect(0.86)
                .frame(width: 50 * scale, height: 32 * scale)
        }
        .padding(.horizontal, 18 * scale)
        .frame(width: 331 * scale, height: 86 * scale)
        .background(Color.white)
        .cornerRadius(16 * scale)
        .overlay(
            RoundedRectangle(cornerRadius: 16 * scale)
                .stroke(Color.black.opacity(0.035), lineWidth: 1 * scale)
        )
        .shadow(color: .black.opacity(0.065), radius: 10 * scale, x: 0, y: 4 * scale)
    }
}

private struct MarathonReadOnlyEmailField: View {
    let email: String
    let scale: CGFloat

    var body: some View {
        Text(email)
            .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 14 * scale))
            .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
            .padding(.horizontal, 18 * scale)
            .frame(width: 331 * scale, height: 52 * scale, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16 * scale)
            .shadow(color: .black.opacity(0.15), radius: 6 * scale, x: 1 * scale, y: 1 * scale)
    }
}

private struct ReadingMarathonLogoMark: View {
    let isLinked: Bool
    let scale: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14 * scale)
                .fill(Color(red: 245 / 255, green: 245 / 255, blue: 247 / 255))
                .frame(width: 52 * scale, height: 52 * scale)

            Image("ReadingMarathonLogo", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 34 * scale, height: 34 * scale)
        }
        .animation(.easeOut(duration: 0.22), value: isLinked)
    }
}

private struct ReadingMarathonInfoBox: View {
    let isLinked: Bool
    let scale: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: 8 * scale) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 12 * scale, weight: .semibold))
                .foregroundColor(
                    isLinked
                    ? FeatureAsset.Color.buttonColor.swiftUIColor
                    : FeatureAsset.Color.textPlaceholder.swiftUIColor
                )

            Text(
                isLinked
                ? "연동하면 홈 · 마이페이지에서 진척도와 랭킹이 자동으로 표시돼요."
                : "지금 연동하지 않아도 괜찮아요. 마이페이지에서 언제든 다시 연동할 수 있어요!"
            )
            .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
            .foregroundColor(
                isLinked
                ? Color(red: 91 / 255, green: 112 / 255, blue: 62 / 255)
                : FeatureAsset.Color.textPlaceholder.swiftUIColor
            )
            .lineSpacing(3 * scale)
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16 * scale)
        .padding(.vertical, 14 * scale)
        .frame(width: 331 * scale, alignment: .leading)
        .background(
            isLinked
            ? FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.08)
            : Color.white
        )
        .cornerRadius(14 * scale)
        .overlay(
            RoundedRectangle(cornerRadius: 14 * scale)
                .stroke(
                    isLinked
                    ? Color.clear
                    : FeatureAsset.Color.textPlaceholder.swiftUIColor.opacity(0.18),
                    lineWidth: 1 * scale
                )
        )
        .shadow(color: .black.opacity(0.07), radius: 9 * scale, x: 0, y: 4 * scale)
    }
}

private struct ThirdPartyAgreementView: View {
    @Binding var isAgreed: Bool
    let scale: CGFloat

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.82)) {
                isAgreed.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 10 * scale) {
                ZStack {
                    Circle()
                        .fill(isAgreed ? FeatureAsset.Color.buttonColor.swiftUIColor : Color.white)
                        .frame(width: 18 * scale, height: 18 * scale)
                        .overlay(
                            Circle()
                                .stroke(
                                    isAgreed ? FeatureAsset.Color.buttonColor.swiftUIColor : FeatureAsset.Color.textPlaceholder.swiftUIColor.opacity(0.35),
                                    lineWidth: 1 * scale
                                )
                        )

                    if isAgreed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10 * scale, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 1 * scale)

                (
                    Text("독서마라톤 계정 연동을 위한 ")
                        .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                    + Text("개인정보 제3자 제공")
                        .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                    + Text("에\n동의합니다.")
                        .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                )
                .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12 * scale))
                .lineSpacing(3 * scale)

                Spacer(minLength: 0)
            }
            .frame(width: 331 * scale, alignment: .leading)
        }
        .buttonStyle(.plain)
        .frame(width: 331 * scale, alignment: .leading)
    }
}

private struct ThirdPartyAgreementBottomPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct SocialLoginButtons: View {
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 26 * scale) {
            SocialLoginButton(imageName: "GoogleLoginIcon", scale: scale)
            SocialLoginButton(imageName: "NaverLoginIcon", scale: scale)
            SocialLoginButton(imageName: "KakaoLoginIcon", scale: scale)
        }
        .frame(width: 331 * scale)
    }
}

private struct SocialLoginButton: View {
    let imageName: String
    let scale: CGFloat

    var body: some View {
        Button {
            UIApplication.hideKeyboard()
        } label: {
            Image(imageName, bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 44 * scale, height: 44 * scale)
        }
        .buttonStyle(.plain)
    }
}

private struct SignUpCompleteStepView: View {
    let name: String
    let isReadingMarathonLinked: Bool
    let scale: CGFloat
    let buttonY: CGFloat

    @Environment(\.dismiss) private var dismiss
    @State private var bookCount = 0

    private var displayName: String {
        name.isEmpty ? "회원" : name
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            CompleteGlowBackground(scale: scale)

            VStack(spacing: 0) {
                SuccessCheckAnimation(scale: scale)
                    .padding(.top, 112 * scale)

                Text("가입 완료!")
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 30 * scale))
                    .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                    .padding(.top, 22 * scale)

                Text("\(displayName) 님, 환영해요.\n대출부터 반납, 독서마라톤까지\nBook - on에서 한 번에 관리해보세요.")
                    .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 15 * scale))
                    .foregroundColor(Color(red: 103 / 255, green: 103 / 255, blue: 109 / 255))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4 * scale)
                    .padding(.top, 18 * scale)

                HStack(spacing: 0) {
                    VStack(spacing: 4 * scale) {
                        Text("\(bookCount)")
                            .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 18 * scale))
                            .foregroundColor(FeatureAsset.Color.buttonColor.swiftUIColor)
                        Text("보유 도서")
                            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 11 * scale))
                            .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                    }
                    .frame(width: 68 * scale)

                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 1 * scale, height: 40 * scale)

                    VStack(spacing: 4 * scale) {
                        Text(isReadingMarathonLinked ? "연동됨" : "미연동")
                            .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 18 * scale))
                            .foregroundColor(
                                isReadingMarathonLinked
                                ? FeatureAsset.Color.buttonColor.swiftUIColor
                                : FeatureAsset.Color.textPlaceholder.swiftUIColor
                            )
                        Text("독서마라톤")
                            .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 11 * scale))
                            .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                    }
                    .frame(width: 78 * scale)
                }
                .frame(height: 62 * scale)
                .padding(.horizontal, 8 * scale)
                .background(Color.white)
                .cornerRadius(14 * scale)
                .overlay(
                    RoundedRectangle(cornerRadius: 14 * scale)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1 * scale)
                )
                .padding(.top, 24 * scale)
            }
            .frame(width: FigmaDesign.size.width * scale)

            PrimaryButton(title: "시작하기", scale: scale) {
                UIApplication.hideKeyboard()
                dismiss()
            }
            .offset(x: 47 * scale, y: buttonY)
        }
        .onAppear {
            bookCount = 0
            var accumulatedDelay = 0.18
            let intervals: [Double] = [0.06, 0.07, 0.08, 0.10, 0.13, 0.17, 0.22, 0.30, 0.40, 0.54]

            for (offset, interval) in intervals.enumerated() {
                accumulatedDelay += interval

                DispatchQueue.main.asyncAfter(deadline: .now() + accumulatedDelay) {
                    withAnimation(.easeOut(duration: 0.08)) {
                        bookCount = offset + 1
                    }
                }
            }
        }
    }
}

private struct CompleteGlowBackground: View {
    let scale: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            FeatureAsset.Color.background.swiftUIColor

            LinearGradient(
                colors: [
                    FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.10),
                    FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.06),
                    FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: FigmaDesign.size.width * scale, height: 430 * scale)
            .offset(y: -80 * scale)

            Circle()
                .fill(FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.16))
                .frame(width: 420 * scale, height: 300 * scale)
                .blur(radius: 42 * scale)
                .offset(y: 8 * scale)
        }
        .frame(width: FigmaDesign.size.width * scale, height: FigmaDesign.size.height * scale)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct SuccessCheckAnimation: View {
    let scale: CGFloat

    @State private var circleScale: CGFloat = 0
    @State private var checkTrim: CGFloat = 0
    @State private var firstRingScale: CGFloat = 0.55
    @State private var firstRingOpacity: CGFloat = 0
    @State private var secondRingScale: CGFloat = 0.55
    @State private var secondRingOpacity: CGFloat = 0
    @State private var rayScale: CGFloat = 0.6
    @State private var rayOpacity: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(FeatureAsset.Color.buttonColor.swiftUIColor, lineWidth: 2 * scale)
                .frame(width: 118 * scale, height: 118 * scale)
                .scaleEffect(firstRingScale)
                .opacity(firstRingOpacity)

            Circle()
                .stroke(FeatureAsset.Color.buttonColor.swiftUIColor, lineWidth: 2 * scale)
                .frame(width: 118 * scale, height: 118 * scale)
                .scaleEffect(secondRingScale)
                .opacity(secondRingOpacity)

            SuccessRayBurst(scale: scale)
                .scaleEffect(rayScale)
                .opacity(rayOpacity)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 143 / 255, green: 201 / 255, blue: 58 / 255),
                            FeatureAsset.Color.buttonColor.swiftUIColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 118 * scale, height: 118 * scale)
                .shadow(color: FeatureAsset.Color.buttonColor.swiftUIColor.opacity(0.42), radius: 22 * scale, x: 0, y: 8 * scale)
                .scaleEffect(circleScale)

            SuccessCheckmarkShape()
                .trim(from: 0, to: checkTrim)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 9 * scale, lineCap: .round, lineJoin: .round)
                )
                .frame(width: 64 * scale, height: 64 * scale)
        }
        .frame(width: 170 * scale, height: 170 * scale)
        .onAppear {
            circleScale = 0
            checkTrim = 0
            firstRingScale = 0.55
            firstRingOpacity = 0
            secondRingScale = 0.55
            secondRingOpacity = 0
            rayScale = 0.6
            rayOpacity = 0

            withAnimation(.interpolatingSpring(stiffness: 210, damping: 15).delay(0.1)) {
                circleScale = 1
            }

            withAnimation(.easeInOut(duration: 0.42).delay(0.5)) {
                checkTrim = 1
            }

            animateRing(delay: 0.35, scale: $firstRingScale, opacity: $firstRingOpacity)
            animateRing(delay: 0.7, scale: $secondRingScale, opacity: $secondRingOpacity)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                rayOpacity = 0.9

                withAnimation(.easeOut(duration: 0.8)) {
                    rayScale = 1.35
                    rayOpacity = 0
                }
            }
        }
    }

    private func animateRing(delay: Double, scale: Binding<CGFloat>, opacity: Binding<CGFloat>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            opacity.wrappedValue = 0.4

            withAnimation(.easeOut(duration: 1.4)) {
                scale.wrappedValue = 1.7
                opacity.wrappedValue = 0
            }
        }
    }
}

private struct SuccessCheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.26, y: rect.minY + rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.43, y: rect.minY + rect.height * 0.70))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.76, y: rect.minY + rect.height * 0.32))
        return path
    }
}

private struct SuccessRayBurst: View {
    let scale: CGFloat

    var body: some View {
        ZStack {
            ray(rotation: 0, yOffset: -73)
            ray(rotation: 180, yOffset: -73)
            ray(rotation: 90, yOffset: -73)
            ray(rotation: 270, yOffset: -73)
            ray(rotation: 45, yOffset: -70)
            ray(rotation: 135, yOffset: -70)
            ray(rotation: 225, yOffset: -70)
            ray(rotation: 315, yOffset: -70)
        }
        .frame(width: 170 * scale, height: 170 * scale)
    }

    private func ray(rotation: Double, yOffset: CGFloat) -> some View {
        Capsule()
            .fill(FeatureAsset.Color.buttonColor.swiftUIColor)
            .frame(width: 4 * scale, height: 18 * scale)
            .offset(y: yOffset * scale)
            .rotationEffect(.degrees(rotation))
    }
}

private struct AgreementBox: View {
    @Binding var isExpanded: Bool
    @Binding var isAgreed: Bool
    @Binding var hasReadAgreement: Bool
    let scale: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("개인정보 수집 및 이용 안내")
                        .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 14 * scale))
                        .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14 * scale, weight: .semibold))
                        .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 8 * scale) {
                        Text("1. 수집 항목")
                            .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                            .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

                        Text("이름, 학교 이메일 주소, 비밀번호, 성별, 학과")
                            .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale))
                            .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)

                        Text("2. 수집 목적")
                            .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                            .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

                        Text("회원 식별 및 관리, 학교 계정 기반 서비스 제공, 공지사항 전달, 독서마라톤 연동 기능 제공")
                            .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale))
                            .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                            .lineSpacing(3 * scale)

                        Text("3. 보유 및 이용 기간")
                            .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 12 * scale))
                            .foregroundColor(FeatureAsset.Color.textPrimary.swiftUIColor)

                        Text("회원 탈퇴 시까지 보관되며, 관련 법령에 따라 보관이 필요한 경우 해당 기간 동안 보관됩니다.")
                            .font(FeatureFontFamily.Pretendard.regular.swiftUIFont(size: 12 * scale))
                            .foregroundColor(FeatureAsset.Color.textPlaceholder.swiftUIColor)
                            .lineSpacing(3 * scale)

                        Color.clear
                            .frame(height: 1 * scale)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: AgreementBottomPreferenceKey.self,
                                        value: proxy.frame(in: .named("AgreementScroll")).minY
                                    )
                                }
                            )
                    }
                    .padding(.trailing, 6 * scale)
                }
                .coordinateSpace(name: "AgreementScroll")
                .frame(height: 96 * scale)
                .onPreferenceChange(AgreementBottomPreferenceKey.self) { bottomY in
                    guard bottomY <= 96 * scale else { return }
                    hasReadAgreement = true
                }
            }

            Button {
                guard hasReadAgreement else {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isExpanded = true
                    }
                    return
                }

                withAnimation(.spring(response: 0.22, dampingFraction: 0.82)) {
                    isAgreed.toggle()
                }
            } label: {
                HStack(spacing: 10 * scale) {
                    ZStack {
                        Circle()
                            .fill(isAgreed ? FeatureAsset.Color.buttonColor.swiftUIColor : Color.white)
                            .frame(width: 18 * scale, height: 18 * scale)
                            .overlay(
                                Circle()
                                    .stroke(
                                        isAgreed ? FeatureAsset.Color.buttonColor.swiftUIColor : FeatureAsset.Color.textPlaceholder.swiftUIColor.opacity(0.25),
                                        lineWidth: 1 * scale
                                    )
                            )

                        if isAgreed {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10 * scale, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    Text("개인정보 수집 및 이용에 동의합니다 (필수)")
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 13 * scale))
                        .foregroundColor(
                            hasReadAgreement
                            ? FeatureAsset.Color.textPrimary.swiftUIColor
                            : FeatureAsset.Color.textPlaceholder.swiftUIColor
                        )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16 * scale)
        .padding(.vertical, 16 * scale)
        .frame(width: 331 * scale, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16 * scale)
        .overlay(
            RoundedRectangle(cornerRadius: 16 * scale)
                .stroke(Color.black.opacity(0.08), lineWidth: 1 * scale)
        )
    }
}

private struct AgreementBottomPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
