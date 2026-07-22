import SwiftUI
import Service

public struct SignUpFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var info = SignUpAccountInfo()
    @State private var currentStep: SignUpFlowStep = .school
    @State private var isRegistering = false
    @State private var registerError: String?
    @State private var verificationSessionId: String?
    @State private var isVerifying = false
    @State private var verificationError: String?

    private let onFinished: () -> Void
    private let registerService: RegisterService

    public init(
        registerService: RegisterService = RegisterService(),
        onFinished: @escaping () -> Void = {}
    ) {
        self.registerService = registerService
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            switch currentStep {
            case .school:
                SignUpStep1View(
                    info: $info,
                    onNext: { move(to: .account) }
                )
            case .account:
                SignUpStep2View(
                    info: $info,
                    isSubmitting: isRegistering,
                    submissionError: registerError,
                    onNext: register
                )
            case .verification:
                SignUpVerificationView(
                    email: "\(info.schoolEmailPrefix)@gsm.hs.kr",
                    isSubmitting: isVerifying,
                    errorMessage: verificationError,
                    onVerify: verifyRegistration,
                    onResend: register
                )
            case .marathon:
                SignUpStep3View(
                    info: $info,
                    onNext: { move(to: .complete) }
                )
            case .complete:
                SignUpCompleteView(
                    name: info.name,
                    hasLinkedMarathon: info.isMarathonLinked,
                    onStart: onFinished
                )
            }

            if currentStep != .complete {
                AppBackButton(scale: 1, action: goBack)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.leading, 18)
                    .padding(.top, 29)
                    .zIndex(200)
            }
        }
        .animation(nil, value: currentStep)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func move(to step: SignUpFlowStep) {
        registerError = nil
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            currentStep = step
        }
    }

    private func register() {
        guard
            !isRegistering,
            let department = info.department?.serverCode,
            let gender = info.gender?.serverCode
        else { return }

        isRegistering = true
        registerError = nil

        let request = RegisterRequest(
            email: "\(info.schoolEmailPrefix)@gsm.hs.kr",
            name: info.name.trimmingCharacters(in: .whitespacesAndNewlines),
            department: department,
            gender: gender,
            password: info.password,
            passwordConfirm: info.passwordConfirm
        )

        Task {
            do {
                let response = try await registerService.register(request)
                await MainActor.run {
                    verificationSessionId = response.sessionId
                    isRegistering = false
                    verificationError = nil
                    move(to: .verification)
                }
            } catch let NetworkError.server(statusCode, _, message) where statusCode == 409 {
                await MainActor.run {
                    isRegistering = false
                    registerError = message ?? "이미 가입된 이메일입니다."
                    verificationError = registerError
                }
            } catch let NetworkError.server(statusCode, _, message) where statusCode == 422 {
                await MainActor.run {
                    isRegistering = false
                    registerError = message ?? "입력한 회원정보를 다시 확인해주세요."
                    verificationError = registerError
                }
            } catch {
                await MainActor.run {
                    isRegistering = false
                    registerError = error.localizedDescription
                    verificationError = registerError
                }
            }
        }
    }

    private func verifyRegistration(_ passcode: String) {
        guard !isVerifying, let verificationSessionId else {
            verificationError = "인증 세션이 없습니다. 인증번호를 다시 요청해주세요."
            return
        }

        isVerifying = true
        verificationError = nil

        Task {
            do {
                let request = RegisterVerificationRequest(
                    sessionId: verificationSessionId,
                    passcode: passcode
                )
                try await registerService.verify(request)
                await MainActor.run {
                    isVerifying = false
                    move(to: .marathon)
                }
            } catch {
                await MainActor.run {
                    isVerifying = false
                    verificationError = error.localizedDescription
                }
            }
        }
    }

    private func goBack() {
        switch currentStep {
        case .school:
            dismiss()
        case .account:
            move(to: .school)
        case .verification:
            move(to: .account)
        case .marathon:
            move(to: .verification)
        case .complete:
            break
        }
    }
}

private extension String {
    var serverCode: String? {
        switch self {
        case "소프트웨어개발과": return "SW"
        case "사물인터넷과": return "IOT"
        case "인공지능과": return "AI"
        default: return nil
        }
    }
}

private enum SignUpFlowStep {
    case school
    case account
    case verification
    case marathon
    case complete
}
