import XCTest
import Rope

final class RopeQueryTests: XCTestCase {

    let creds = Secrets.DBTestCredentials()
    var conn: Rope? // auto-tested optional db connection

    override func setUp() {
        super.setUp()
        // create connection
        conn = try? Rope.connect(credentials: creds)
        XCTAssertNotNil(conn)
        guard let db = conn else { return }
        var res = try! db.query("DROP TABLE IF EXISTS rope")
        XCTAssertNotNil(res)
        // create a table with different types as test, payload can be nil
        var sql = "CREATE TABLE rope (id SERIAL PRIMARY KEY, payload TEXT, is_ok BOOLEAN default FALSE, "
        sql += "my_date DATE default current_timestamp, my_ts TIMESTAMP default current_timestamp);"
        res = try! db.query(sql)
        XCTAssertNotNil(res)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEmptyQueryStatement() {
        XCTAssertThrowsError(try conn!.query(""))
    }

    func testInvalidQueryStatement() {
        XCTAssertThrowsError(
            try conn!.query("CREATE TABLE IF NOT EXISTS rope(id SERIAL PRIMARY KEY, firstname VARCHAR(255) lastname VARCHAR(255))") // comma is missing
        )
    }

    func testBasicQueryStatement() {
        // the following SQL should always work, even on empty databases
        let res = try! conn!.query("SELECT version();")
        XCTAssertNotNil(res)
    }

    func testQueryInsertStatement() {
        let res = try! conn!.query("INSERT INTO rope (payload) VALUES('Rope is awesome!')")
        XCTAssertNotNil(res)
    }

    func testQuerySelectRows() {
        // guard let db = conn else { return }
        // we are enforcing here to get a crash during test if needed
        // in production you should be less aggressive!
        var res = try! conn!.query("SELECT * FROM rope ORDER BY id")
        XCTAssertNotNil(res)
        var rows = res?.rows()
        XCTAssertNotNil(rows)
        XCTAssertEqual(rows?.count, 0)
        // insert 2 rows
        res = try! conn!.query("INSERT INTO rope (payload) VALUES('Rope is awesome!')")
        XCTAssertNotNil(res)
        res = try! conn!.query("INSERT INTO rope (payload) VALUES('Rope is dope!')")
        XCTAssertNotNil(res)
        // select the rows
        res = try! conn!.query("SELECT * FROM rope ORDER BY id DESC")
        XCTAssertNotNil(res)
        rows = res?.rows()
        XCTAssertNotNil(rows)
        XCTAssertEqual(rows?.count, 2)
    }

    func testQuerySelectRowTypes() {
        // insert 2 rows
        var res = try! conn!.query("INSERT INTO rope (payload) VALUES('Rope is awesome!')")
        XCTAssertNotNil(res)
        res = try! conn!.query("INSERT INTO rope (payload) VALUES('Rope is dope!')")
        XCTAssertNotNil(res)
        // select the rows
        res = try! conn!.query("SELECT * FROM rope ORDER BY id DESC")
        XCTAssertNotNil(res)
        guard let selectRes = res, let rows = res?.rows() else { return }
        XCTAssertEqual(rows.count, 2)

        let val = selectRes.row(0, columnName: "payload") as? String
        XCTAssertNotNil(val)
        XCTAssertEqual(val!, "Rope is dope!")
        /*
         // DOES NOT WORK because row returns string?!?!
         val = selectRes.row(0, columnName: "id") as? Int
         XCTAssertNotNil(val)
         XCTAssertEqual(val!, 2)
         */

        /*
         let myTS = res?.row(0, columnName: "my_ts") as? Int
         XCTAssertGreaterThan(myTS!, 1484574245)
         */

        // let firstRow = selectRes.row(0)
    }

    /*
     func testQueryIsertStatementWithParams() {

     var res = try! conn!.query("CREATE TABLE IF NOT EXISTS first_rope(id SERIAL PRIMARY KEY, payload TEXT)")

     let dateStr = formatDate("HH:mm:ss.SSS")
     let text = "Hello, I am text created at " + dateStr // + NSUUID().uuidString

     res = try! conn!.query(statement: "INSERT INTO first_rope (payload) VALUES($1)", params: [text])
     XCTAssertNotNil(res)
     // TO BE CONTINUED ...

     //if let res = res {
     //    print(res)
     //    }
     }
     */

    /*
     func testInvalidQueryStatement() {
     XCTAssertThrowsError(
     try conn!.query("CREATE TABLE IF NOT EXISTS second_rope(id SERIAL PRIMARY KEY, firstname VARCHAR(255) lastname VARCHAR(255))") // comma is missing
     )
     }

     func testQueryInsertStatementWithSeveralParams() {
     let res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])
     XCTAssertNotNil(res)
     }

     func testSelectQuery() {
     var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

     res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
     XCTAssertNotNil(res)

     XCTAssertEqual(res?.rowsCount, 1)
     }

     func testGetField() {
     var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

     res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
     XCTAssertNotNil(res)

     let rows = res?.rows()

     XCTAssertNotNil(rows)
     XCTAssertEqual(rows?.count, 1)
     }

     func testGetId() {
     var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

     res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
     XCTAssertNotNil(res)

     let id = res?.row(0, columnName: "id") as? Int
     XCTAssertEqual(id, 1)
     }

     func testGetFirstname() {
     var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

     res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
     XCTAssertNotNil(res)

     let firstName = res?.row(0, columnName: "firstname") as? String
     XCTAssertEqual(firstName, "Johannes")
     }

     func testGetLastname() {
     var res = try! conn!.query(statement: "INSERT INTO second_rope (firstname, lastname) VALUES($1,$2)", params: ["Johannes", "Erhardt"])

     res = try! conn!.query("SELECT * FROM second_rope ORDER BY id")
     XCTAssertNotNil(res)

     let row = res?.row(0)

     let lastName = row?["lastname"] as? String
     XCTAssertEqual(lastName, "Erhardt")
     }
     */
}

// HELPERS

fileprivate let formatter = DateFormatter()

/// returns a formatted date string
/// optionally in a given abbreviated timezone like "UTC"
fileprivate func formatDate(_ dateFormat: String, timeZone: String = "") -> String {
    let formatter = DateFormatter()

    if !timeZone.isEmpty {
        formatter.timeZone = TimeZone(abbreviation: timeZone)
    }
    formatter.dateFormat = dateFormat

    let dateStr = formatter.string(from: Date())
    return dateStr
}
