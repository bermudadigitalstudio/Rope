import XCTest
import Rope

final class RopeConnectionTests: XCTestCase {

    let creds = Secrets.DBTestCredentials()

    /*
     func testInvalidConnection() {
     // the test seems to run infinitely, needs FIX
     XCTAssertThrowsError(
     try Rope.connect(host: "invalidHost", port: 1234, dbName: "invalidDatabaseName", user: "invalidUserName", password: "")
     )
     } */

    func testConnectWithParams() {
        // if the test fails then the credentials in Secrets.swift are wrong
        let conn = try? Rope.connect(host: creds.host, port: creds.port,
                                     dbName: creds.dbName, user: creds.user,
                                     password: creds.password)
        XCTAssertNotNil(conn)
    }

    func testConnectWithStruct() {
        // if the test fails then the credentials in Secrets.swift are wrong
        let conn = try? Rope.connect(credentials: creds)
        XCTAssertNotNil(conn)
    }
}
