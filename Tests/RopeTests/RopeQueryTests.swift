import XCTest
import Rope

final class RopeQueryTests: XCTestCase {
    
    func testEmptyQueryStatement() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)
        

        XCTAssertThrowsError(try conn!.query(""))
    }

    func testQueryInsertStatement() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)

        let res = try! conn!.query("CREATE TABLE IF NOT EXISTS rope(id SERIAL PRIMARY KEY, payload TEXT)")
        XCTAssertNotNil(res)
    }
    
}
