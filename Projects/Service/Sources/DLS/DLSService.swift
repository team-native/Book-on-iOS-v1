import Foundation

public struct DLSBookListData<Book: Decodable & Sendable>: Decodable, Sendable {
    public let count: Int
    public let bookList: [Book]
}

public struct DLSStudentListData: Decodable, Sendable {
    public let count: Int
    public let studentList: [DLSStudent]
}

public struct DLSStudent: Decodable, Sendable {
    public let userKey: String
    public let userNo: String
    public let name: String

    private enum CodingKeys: String, CodingKey {
        case userKey = "user_key"
        case userNo = "user_no"
        case name
    }
}

public struct DLSCurrentLoan: Decodable, Sendable {
    public let loanKey: String
    public let registrationNumber: String
    public let title: String
    public let loanDate: String
    public let returnPlanDate: String

    private enum CodingKeys: String, CodingKey {
        case loanKey = "loan_key"
        case registrationNumber = "reg_no"
        case title
        case loanDate = "loan_date"
        case returnPlanDate = "rtn_plan_date"
    }
}

public struct DLSBookInfo: Decodable, Sendable {
    public let registrationNumber: String
    public let title: String
    public let author: String?
    public let publisher: String?
    public let publicationYear: String?
    public let coverImagePath: String?
    public let isbn: String?
    public let callNumber: String?
    public let locationDescription: String?
    public let statusDescription: String?
    public let returnPlanDate: String?

    private enum CodingKeys: String, CodingKey {
        case registrationNumber = "reg_no"
        case title
        case author = "aut_nm"
        case publisher
        case publicationYear = "pblcn_yr"
        case coverImagePath = "cover_img_path"
        case isbn = "ea_isbn"
        case callNumber = "call_no"
        case locationDescription = "location_desc"
        case statusDescription = "status_desc"
        case returnPlanDate = "rtn_plan_date"
    }
}

public struct DLSLoanHistory: Decodable, Sendable {
    public let registrationNumber: String
    public let title: String
    public let loanDate: String
    public let returnDate: String?

    private enum CodingKeys: String, CodingKey {
        case registrationNumber = "reg_no"
        case title
        case loanDate = "loan_date"
        case returnDate = "return_date"
    }
}

public struct DLSExecutionResult: Decodable, Sendable {
    public let statusDescription: String
}

public struct DLSService: Sendable {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    public func fetchReturnDates() async throws -> DLSBookListData<DLSCurrentLoan> {
        try await get(path: "/dls/returnDate", as: DLSBookListData<DLSCurrentLoan>.self)
    }

    public func searchStudents(name: String) async throws -> DLSStudentListData {
        try await get(path: "/dls/searchStudent", query: ["name": name], as: DLSStudentListData.self)
    }

    public func fetchCurrentLoans(userKey: String, userNumber: String) async throws -> DLSBookListData<DLSCurrentLoan> {
        try await get(
            path: "/dls/currentLoan",
            query: ["user_key": userKey, "user_no": userNumber],
            as: DLSBookListData<DLSCurrentLoan>.self
        )
    }

    public func fetchBookInfo(registrationNumbers: String) async throws -> DLSBookListData<DLSBookInfo> {
        try await get(path: "/dls/bookInfo", query: ["reg_nos": registrationNumbers], as: DLSBookListData<DLSBookInfo>.self)
    }

    public func fetchLoanHistory(
        userKey: String,
        startDate: String? = nil,
        endDate: String? = nil
    ) async throws -> DLSBookListData<DLSLoanHistory> {
        var query = ["user_key": userKey]
        query["start_date"] = startDate
        query["end_date"] = endDate
        return try await get(path: "/dls/loanHistory", query: query, as: DLSBookListData<DLSLoanHistory>.self)
    }

    public func execute(registrationNumber: String, userKey: String) async throws -> DLSExecutionResult {
        try await get(
            path: "/dls/execution",
            query: ["reg_no": registrationNumber, "user_key": userKey],
            as: DLSExecutionResult.self
        )
    }

    public func searchBooks(query: String) async throws -> DLSBookListData<DLSBookInfo> {
        try await get(path: "/dls/searchBook", query: ["query": query], as: DLSBookListData<DLSBookInfo>.self)
    }

    public func extendLoan(userKey: String, loanKey: String) async throws -> DLSExecutionResult {
        try await get(
            path: "/dls/extendLoan",
            query: ["user_key": userKey, "loan_key": loanKey],
            as: DLSExecutionResult.self
        )
    }

    private func get<Response: Decodable>(
        path: String,
        query: [String: String] = [:],
        as type: Response.Type
    ) async throws -> Response {
        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        return try await client.send(
            APIEndpoint(path: path, queryItems: queryItems, requiresAuthorization: true),
            as: type
        ).data
    }
}
