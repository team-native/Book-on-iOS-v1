import XCTest
@testable import Service

final class APIResponseTests: XCTestCase {
    func testDecodesErrorCodeEnvelope() throws {
        let data = Data(#"{"errorCode":0,"message":"ok","data":{"value":"books"}}"#.utf8)
        let response = try JSONDecoder().decode(APIResponse<TestPayload>.self, from: data)

        XCTAssertEqual(response.errorCode, 0)
        XCTAssertEqual(response.message, "ok")
        XCTAssertEqual(response.data.value, "books")
    }

    func testDecodesSuccessEnvelope() throws {
        let data = Data(#"{"success":true,"message":"ok","data":{"value":"favorites"}}"#.utf8)
        let response = try JSONDecoder().decode(APIResponse<TestPayload>.self, from: data)

        XCTAssertEqual(response.errorCode, 0)
        XCTAssertEqual(response.data.value, "favorites")
    }

    func testMapsUnsuccessfulStatusToErrorCode() throws {
        let data = Data(#"{"success":false,"status":4010,"data":{"value":"expired"}}"#.utf8)
        let response = try JSONDecoder().decode(APIResponse<TestPayload>.self, from: data)

        XCTAssertEqual(response.errorCode, 4010)
        XCTAssertEqual(response.data.value, "expired")
    }

    func testRejectsEnvelopeWithoutSuccessIndicator() {
        let data = Data(#"{"message":"missing status","data":{"value":"x"}}"#.utf8)

        XCTAssertThrowsError(try JSONDecoder().decode(APIResponse<TestPayload>.self, from: data))
    }
}

private struct TestPayload: Decodable, Equatable {
    let value: String
}
