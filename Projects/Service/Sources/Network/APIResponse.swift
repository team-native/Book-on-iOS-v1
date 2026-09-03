import Foundation

public struct APIResponse<ResponseData: Decodable>: Decodable {
    public let errorCode: Int
    public let message: String
    public let data: ResponseData

    private enum CodingKeys: String, CodingKey {
        case errorCode
        case success
        case status
        case message
        case data
    }

    public init(errorCode: Int, message: String, data: ResponseData) {
        self.errorCode = errorCode
        self.message = message
        self.data = data
    }

    /// 기존 `errorCode` 응답과 서버의 `success`/`status` 응답을 모두 지원합니다.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        data = try container.decode(ResponseData.self, forKey: .data)

        if let errorCode = try container.decodeIfPresent(Int.self, forKey: .errorCode) {
            self.errorCode = errorCode
            return
        }

        guard let success = try container.decodeIfPresent(Bool.self, forKey: .success) else {
            throw DecodingError.keyNotFound(
                CodingKeys.errorCode,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "응답에 errorCode 또는 success가 없습니다."
                )
            )
        }

        errorCode = success ? 0 : (try container.decodeIfPresent(Int.self, forKey: .status) ?? -1)
    }
}

struct APIErrorResponse: Decodable {
    let errorCode: Int
    let message: String
    let data: APIErrorDetail?
}

public struct APIErrorDetail: Decodable, Sendable {
    public let service: String?
    public let reason: String?
    public let path: String?
    public let httpStatus: Int?
    public let proxyStatus: String?
    public let timeout: Bool?
}
