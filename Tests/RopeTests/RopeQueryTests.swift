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
        var sql = "CREATE TABLE rope (id SERIAL PRIMARY KEY, my_text TEXT, my_bool BOOLEAN default FALSE"
        sql += ", my_varchar VARCHAR(3) default 'abc', my_char CHAR(1) default 'x', my_null_text TEXT default null"
        sql += ", my_real REAL default 123.456, my_double DOUBLE PRECISION default 456.789"
        // sql += ", row_to_json(row(1,'foo'))"
        sql += ", my_date DATE default current_timestamp, my_ts TIMESTAMP default current_timestamp);"
        res = try! db.query(sql)
        XCTAssertNotNil(res)
    }

    override func tearDown() {
        super.tearDown()
    }

    /*func testEmptyQueryStatement() {
        XCTAssertThrowsError(try conn!.query(""))
    }

    func testInvalidQueryStatement() {
        XCTAssertThrowsError(
            // comma is missing
            try conn!.query("CREATE TABLE IF NOT EXISTS rope(id SERIAL PRIMARY KEY name TEXT))")
        )
    }

    func testBasicQueryStatement() {
        // the following SQL should always work, even on empty databases
        let res = try! conn!.query("SELECT version();")
        XCTAssertNotNil(res)
    }

    func testQueryInsertStatement() {
        let res = try! conn!.query("INSERT INTO rope (my_text) VALUES('Rope is awesome!')")
        XCTAssertNotNil(res)
        XCTAssertEqual(res?.rows().count, 0)
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
        res = try! conn!.query("INSERT INTO rope (my_text) VALUES('Rope is awesome!')")
        XCTAssertNotNil(res)
        res = try! conn!.query("INSERT INTO rope (my_text) VALUES('Rope is dope!')")
        XCTAssertNotNil(res)

        // select the rows
        res = try! conn!.query("SELECT * FROM rope ORDER BY id DESC")
        XCTAssertNotNil(res)
        rows = res?.rows()
        XCTAssertNotNil(rows)
        XCTAssertEqual(rows?.count, 2)
    }*/

    func testQuerySelectRowTypes() {
        // insert 2 rows
        var res = try! conn!.query("INSERT INTO rope (my_text) VALUES('Rope is awesome!')")
        XCTAssertNotNil(res)
        res = try! conn!.query("INSERT INTO rope (my_text) VALUES('Rope is dope!')")
        XCTAssertNotNil(res)

        // select the rows
        res = try! conn!.query("SELECT * FROM rope ORDER BY id DESC")
        XCTAssertNotNil(res)

        guard let rows = res?.rows() else { return }
        XCTAssertEqual(rows.count, 2)

        // test the different types
        ///////////////////////////

        // text to string
        let myText = rows[0]["my_text"] as? String
        XCTAssertEqual(myText!, "Rope is dope!")

        // serial to int
        let id = rows[0]["id"] as? Int
        XCTAssertEqual(id!, 2)

        // check if order is correct
        let idNextRow = rows[1]["id"] as? Int
        XCTAssertEqual(idNextRow!, 1)

        // boolean to bool
        let isOk = rows[0]["my_bool"] as? Bool
        XCTAssertFalse(isOk!)

        // varchar to string
        let myVarchar = rows[0]["my_varchar"] as? String
        XCTAssertEqual(myVarchar!, "abc")

        // char to string
        let myChar = rows[0]["my_char"] as? String
        XCTAssertEqual(myChar!, "x")

        // null value of text to string
        let myNullText = rows[0]["my_null_text"] as? String
        XCTAssertEqual(myNullText, nil)

        // real to float
        let myReal = rows[0]["my_real"] as? Float
        XCTAssertEqual(myReal!, 123.456)

        // double to float
        let myDouble = rows[0]["my_double"] as? Float
        XCTAssertEqual(myDouble!, 456.789)

        // timestamp to int
        let myTS = rows[0]["my_ts"] as? Date
        XCTAssertNotNil(myTS)

        // date to int
        let myDate = rows[0]["my_date"] as? Date
        XCTAssertNotNil(myDate)

        // conversion from integer to string returns nil
        let idString = rows[0]["id"] as? String
        XCTAssertNil(idString)

        // a non-existing column is nil
        let idx = rows[0]["xid"] as? Int
        XCTAssertNil(idx)
    }
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
