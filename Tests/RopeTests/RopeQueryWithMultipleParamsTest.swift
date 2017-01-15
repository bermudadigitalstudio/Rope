import XCTest
import Rope

final class RopeQueryWithSeveralParamsTest: XCTestCase {

    override func setUp() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        _ = try! conn!.query("DROP TABLE IF EXISTS second_rope")
        _ = try! conn!.query("CREATE TABLE IF NOT EXISTS second_rope(id SERIAL PRIMARY KEY, firstname VARCHAR(255), lastname VARCHAR(255))")
    }

    func testInvalidQueryStatement() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        XCTAssertThrowsError(
            try conn!.query("CREATE TABLE IF NOT EXISTS second_rope(id SERIAL PRIMARY KEY, firstname VARCHAR(255) lastname VARCHAR(255))") // comma is missing
        )
    }

    func testQueryInsertStatementWithSeveralParams() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        let res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])
        XCTAssertNotNil(res)
    }
}
