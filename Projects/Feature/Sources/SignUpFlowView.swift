import SwiftUI
import Service

public struct SignUpFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var info = SignUpAccountInfo()
    @State private var currentStep: SignUpFlowStep = .school
    @State private var isRegistering = false
    @State private var registerError: String?

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
                try await registerService.register(request)
                isRegistering = false
                move(to: .marathon)
            } catch let NetworkError.server(statusCode, _, message) where statusCode == 409 {
                isRegistering = false
                registerError = message ?? "이미 가입된 이메일입니다."
            } catch let NetworkError.server(statusCode, _, message) where statusCode == 422 {
                isRegistering = false
                registerError = message ?? "입력한 회원정보를 다시 확인해주세요."
            } catch {
                isRegistering = false
                registerError = error.localizedDescription
            }
        }
    }

    private func goBack() {
        switch currentStep {
        case .school:
            dismiss()
        case .account:
            move(to: .school)
        case .marathon:
            move(to: .account)
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
    case marathon
    case complete
}
