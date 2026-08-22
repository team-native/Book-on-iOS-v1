import Foundation

public struct LoanExtensionResult: Decodable, Sendable {
    public let loanId: Int
    public let previousDueDate: String
    public let newDueDate: String
    public let extensionCount: Int
    public let extensionAvailable: Bool
}

public struct CurrentLoan: Decodable, Sendable, Identifiable {
    public let loanId: Int
    public let bookId: Int
    public let title: String
    public let author: String
    public let borrowedAt: String
    public let dueDate: String
    public let dDay: Int
    public let extensionAvailable: Bool
    public let status: String
    public var id: Int { loanId }
}

public struct CurrentLoanList: Decodable, Sendable {
    public let items: [CurrentLoan]
}

public struct LoanHistoryItem: Decodable, Sendable, Identifiable {
    public let loanId: Int
    public let bookId: Int
    public let title: String
    public let borrowedAt: String
    public let dueDate: String
    public let returnedAt: String?
    public let status: String
    public var id: Int { loanId }
}

public struct LoanPagination: Decodable, Sendable {
    public let page: Int
    public let size: Int
    public let totalCount: Int
    public let totalPages: Int
    public let hasNext: Bool
}

public struct LoanHistoryData: Decodable, Sendable {
    public let items: [LoanHistoryItem]
    public let pagination: LoanPagination
}

public struct LoanService: Sendable {
    private let client: APIClient
    public init(client: APIClient = APIClient()) { self.client = client }

    public func extendLoan(loanId: Int) async throws -> LoanExtensionResult {
        try await client.send(
            APIEndpoint(path: "/loans/\(loanId)/extension", method: .post, requiresAuthorization: true),
            as: LoanExtensionResult.self
        ).data
    }

    public func fetchCurrentLoans() async throws -> [CurrentLoan] {
        try await client.send(
            APIEndpoint(path: "/me/loans/current", requiresAuthorization: true),
            as: CurrentLoanList.self
        ).data.items
    }

    public func fetchHistory(status: String = "ALL", page: Int = 1, size: Int = 20) async throws -> LoanHistoryData {
        let query = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size)),
            URLQueryItem(name: "status", value: status),
        ]
        return try await client.send(
            APIEndpoint(path: "/me/loans/history", queryItems: query, requiresAuthorization: true),
            as: LoanHistoryData.self
        ).data
    }
}
