import Foundation

enum UserFacingError {
    static func message(for error: Error) -> String? {
        if error is CancellationError { return nil }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .cancelled:
                return nil
            case .notConnectedToInternet, .networkConnectionLost:
                return "인터넷 연결을 확인한 뒤 다시 시도해주세요."
            case .timedOut:
                return "연결 시간이 초과되었습니다. 다시 시도해주세요."
            case .secureConnectionFailed, .serverCertificateUntrusted,
                 .serverCertificateHasBadDate, .serverCertificateNotYetValid:
                return "보안 연결을 확인할 수 없습니다. 잠시 후 다시 시도해주세요."
            default:
                return "서버에 연결하지 못했습니다. 잠시 후 다시 시도해주세요."
            }
        }

        return error.localizedDescription
    }
}
