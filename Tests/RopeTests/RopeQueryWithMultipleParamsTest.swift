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

    func testSelectQuery() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

        res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
        XCTAssertNotNil(res)

        XCTAssertEqual(res?.rowsCount, 1)
    }

    func testGetField() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

        res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
        XCTAssertNotNil(res)

        let rows = res?.rows()

        XCTAssertNotNil(rows)
        XCTAssertEqual(rows?.count, 1)
    }

    func testGetId() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

        res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
        XCTAssertNotNil(res)

        let id = res?.row(0, columnName: "id") as? Int32
        XCTAssertEqual(id, 1)
    }

    func testGetFirstname() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

        res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
        XCTAssertNotNil(res)

        let firstName = res?.row(0, columnName: "firstname") as? String
        XCTAssertEqual(firstName, "Johannes")
    }

    func testGetLastname() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

        res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
        XCTAssertNotNil(res)

        let row = res?.row(0)

        let lastName = row?["lastname"] as? String
        XCTAssertEqual(lastName, "Erhardt")
    }
}
