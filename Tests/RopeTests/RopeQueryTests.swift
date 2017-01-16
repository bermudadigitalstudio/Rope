import XCTest
import Rope

final class RopeQueryTests: XCTestCase {

    let creds = Secrets.DBTestCredentials()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEmptyQueryStatement() {
        let conn = try? Rope.connect(credentials: creds)
        XCTAssertNotNil(conn)

        XCTAssertThrowsError(try conn!.query(""))
    }

    func testQueryInsertStatement() {
        let conn = try? Rope.connect(credentials: creds)
        XCTAssertNotNil(conn)

        let res = try! conn!.query("CREATE TABLE IF NOT EXISTS rope(id SERIAL PRIMARY KEY, payload TEXT)")
        XCTAssertNotNil(res)
    }

    func testReadmeExample() {
        // confirms that the README example is actually working

        // establish connection
        let conn = try? Rope.connect(credentials: creds)
        guard let db = conn else { return }

        // run query
        let res = try! db.query("SELECT version();")
        XCTAssertNotNil(res)
        // TO BE CONTINUED ...
        /*
         if let res = res {
         print(res)
         } */
    }

    /*
     // FIX: is breaking due to test not being atomic!
     func testQueryIsertStatementWithParams() {
     let conn = try? Rope.connect(credentials: creds)
     XCTAssertNotNil(conn)

     let res = try! conn!.query(statement: "INSERT INTO rope (payload) VALUES($1)", params: ["Rope is awesome!"])
     XCTAssertNotNil(res)
     } */
}
