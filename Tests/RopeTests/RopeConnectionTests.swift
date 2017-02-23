import XCTest
import Rope

final class RopeConnectionTests: XCTestCase {

    let creds = TestCredentials.getCredentials()

    func testConnectWithParams() {
        // if the test fails then the credentials in Secrets.swift are wrong
        guard let _ = try? Rope.connect(host: creds.host, port: creds.port,
            dbName: creds.dbName, user: creds.user, password: creds.password) else {
            XCTFail("conn should not be nil")
            return
        }
    }

    func testConnectWithStruct() {
        // if the test fails then the credentials in Secrets.swift are wrong
        guard let _ = try? Rope.connect(credentials: creds) else {
            XCTFail("conn should not be nil")
            return
        }
    }
}
