import XCTest
@testable import Feature

final class PushNotificationRouteTests: XCTestCase {
    func testLoanDuePayloadOpensLoanHistory() {
        let route = PushNotificationRoute(userInfo: ["type": "loan_due"])

        guard case .loanHistory = route else {
            return XCTFail("Expected loan_due to open loan history")
        }
    }

    func testNoticePayloadOpensNotices() {
        let route = PushNotificationRoute(userInfo: ["type": "notice"])

        guard case .notices = route else {
            return XCTFail("Expected notice to open notices")
        }
    }

    func testNewBookPayloadOpensBookDetail() {
        let route = PushNotificationRoute(userInfo: ["type": "new_book", "bookId": 42])

        guard case let .bookDetail(bookID) = route, bookID == 42 else {
            return XCTFail("Expected new_book with bookId to open that book")
        }
    }

    func testNewBookDeepLinkOpensBookDetail() {
        let route = PushNotificationRoute(type: "new_book", deepLink: "/books/73")

        guard case let .bookDetail(bookID) = route, bookID == 73 else {
            return XCTFail("Expected new_book deep link to open that book")
        }
    }

    func testNewBookWithoutBookIDOpensNewArrivals() {
        let route = PushNotificationRoute(userInfo: ["type": "new_book"])

        guard case .newArrivals = route else {
            return XCTFail("Expected new_book without an ID to open new arrivals")
        }
    }

    func testUnknownPayloadTypeIsIgnored() {
        XCTAssertNil(PushNotificationRoute(userInfo: ["type": "unknown_type"]))
    }
}
