import Foundation

public enum APIConfiguration {
    public static let baseURL: URL = {
        let environmentURL = ProcessInfo.processInfo.environment["BOOK_ON_API_BASE_URL"]
        let configuredURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
        let value = environmentURL ?? configuredURL ?? "https://bookon.team-native.kr"
        guard let url = URL(string: value) else {
            preconditionFailure("API_BASE_URL이 올바른 URL이 아닙니다.")
        }
        return url
    }()
}
