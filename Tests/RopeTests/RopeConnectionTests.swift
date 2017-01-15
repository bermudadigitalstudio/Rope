import XCTest
import Rope

final class RopeConnectionTests: XCTestCase {

    func testValidConnection() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)
    }

    func testInvalidConnection() {
        XCTAssertThrowsError(
            try Rope.connect(host: "invalidHost", port: 1234, dbName: "invalidDatabaseName", user: "invalidUserName", password: "")
        )
    }
}
