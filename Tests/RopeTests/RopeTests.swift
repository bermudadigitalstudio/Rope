import XCTest
import Rope

final class RopeTests: XCTestCase {

    func testValidConnection() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")

        XCTAssertNotNil(conn)
    }
    
    func testInvalidConnection() {
        var conn: Rope? = nil
        
        do {
            conn = try Rope.connect(host: "invalidHost", port: 1234, dbName: "invalidDatabaseName", user: "invalidUserName",  password: "")
            return
        } catch let error {
            XCTAssertNotNil(error)
            XCTAssertNil(conn)
        }
    }
    
    func testClosedConnection() {
        let conn = try? Rope.connect(dbName: "johanneserhardt", user: "johanneserhardt", password: "")
        XCTAssertNotNil(conn)
        
        try? conn!.close()
        XCTAssertFalse(conn!.connected)
    }

}
