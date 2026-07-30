import Foundation

public struct APIResponse<ResponseData: Decodable>: Decodable {
    public let errorCode: Int
    public let message: String
    public let data: ResponseData

    public init(errorCode: Int, message: String, data: ResponseData) {
        self.errorCode = errorCode
        self.message = message
        self.data = data
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
