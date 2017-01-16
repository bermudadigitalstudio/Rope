import XCTest
import Rope

final class RopeQueryTests: XCTestCase {

    let creds = Secrets.DBTestCredentials()
    var conn: Rope? // successfully established db connection

    override func setUp() {
        super.setUp()
        // create connection
        conn = try? Rope.connect(credentials: creds)
        XCTAssertNotNil(conn)
        guard let db = conn else { return }
        var res = try! db.query("DROP TABLE IF EXISTS rope")
        XCTAssertNotNil(res)
        res = try! db.query("CREATE TABLE rope(id SERIAL PRIMARY KEY, payload TEXT)")
        XCTAssertNotNil(res)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEmptyQueryStatement() {
        XCTAssertThrowsError(try conn!.query(""))
    }

    func testBasicQueryStatement() {
        // the following SQL should always work, even on empty databases
        let res = try! conn!.query("SELECT version();")
        XCTAssertNotNil(res)
    }

    func testQueryInsertStatement() {
        let res = try! conn!.query("INSERT INTO rope (payload) VALUES('foo')")
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
