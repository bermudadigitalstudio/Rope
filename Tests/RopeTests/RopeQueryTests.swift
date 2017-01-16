import XCTest
import Rope

final class RopeQueryTests: XCTestCase {

    override func setUp() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        _ = try! conn!.query("DROP TABLE IF EXISTS first_rope")
    }

    func testEmptyQueryStatement() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        XCTAssertThrowsError(try conn!.query(""))
    }

    func testQueryInsertStatement() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        var res = try! conn!.query("CREATE TABLE IF NOT EXISTS first_rope(id SERIAL PRIMARY KEY, payload TEXT)")

        res = try! conn!.query("INSERT INTO first_rope (payload) VALUES('Rope is awesome!')")
        XCTAssertNotNil(res)
    }

    let formatter = DateFormatter()

    /// returns a formatted date string
    /// optionally in a given abbreviated timezone like "UTC"
    func formatDate(_ dateFormat: String, timeZone: String = "") -> String {
        let formatter = DateFormatter()

        if !timeZone.isEmpty {
            formatter.timeZone = TimeZone(abbreviation: timeZone)
        }
        formatter.dateFormat = dateFormat

        let dateStr = formatter.string(from: Date())
        return dateStr
    }

    func testQueryIsertStatementWithParams() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        var res = try! conn!.query("CREATE TABLE IF NOT EXISTS first_rope(id SERIAL PRIMARY KEY, payload TEXT)")

        let dateStr = formatDate("HH:mm:ss.SSS")
        let text = "Hello, I am text created at " + dateStr // + NSUUID().uuidString

        res = try! conn!.query(statement: "INSERT INTO first_rope (payload) VALUES($1)", params: [text])
        XCTAssertNotNil(res)
    }
}
