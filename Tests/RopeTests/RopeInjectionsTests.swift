import XCTest
import Rope
import Foundation

final class RopeInjectionTests: XCTestCase {

    let creds = TestCredentials.getCredentials()
    var conn: Rope?

    override func setUp() {
        super.setUp()

        guard let db = try? Rope.connect(credentials: creds) else {
            XCTFail("conn should not be nil")
            return
        }
        conn = db
    }

    func testSQLInjection() {
        let seedStatement = "CREATE TEMPORARY TABLE users(id SERIAL PRIMARY KEY, name text); "
        let sql = "INSERT INTO users(name) VALUES ('Sebastian'),('Thomas'),('Johannes'),('Gabriel')"

        guard let _ = try? conn?.query(seedStatement),
            let _ = try? conn?.query(sql) else {
                XCTFail("res should not be nil"); return
        }

        let maliciousInput = "lol'; INSERT INTO users(name) VALUES ('Black hat hacker') --"

        XCTAssertThrowsError(
            try conn?.query("SELECT * FROM users WHERE name = '\(maliciousInput)'")
        )

        func getLatestUserName() -> String? {
            guard let users = try? conn?.query("SELECT * FROM users") else {
                return nil
            }
            let latestUser = users?.rows().last?["name"] as? String
            return latestUser
        }

        XCTAssertNotEqual(getLatestUserName(), "Black hat hacker")

        // Reset and try again
        guard let _ = try? conn?.query("DISCARD TEMPORARY"),
            let _ = try? conn?.query(seedStatement),
            let _ = try? conn?.query("SELECT * FROM users WHERE name = $1", params: [maliciousInput]) else {
                XCTFail("res should not be nil"); return
        }

        XCTAssertNotEqual(getLatestUserName(), "Black hat hacker")
    }
}
