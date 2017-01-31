import XCTest
import Rope
import Foundation

final class RopeQueryTests: XCTestCase {

    let creds = TestCredentials.getCredentials()

    var conn: Rope? // auto-tested optional db connection

    override func setUp() {
        super.setUp()

        // create connection
        guard let db = try? Rope.connect(credentials: creds) else {
            XCTFail("conn should not be nil")
            return
        }
        conn = db
        
        guard let _ = try? db.query("DROP TABLE IF EXISTS rope") else {
            XCTFail("_ should not be nil")
            return
        }

        // create a table with different types as test, payload can be nil
        var sql = "CREATE TABLE rope (id SERIAL PRIMARY KEY, my_text TEXT, my_bool BOOLEAN default FALSE"
        sql += ", my_varchar VARCHAR(3) default 'abc', my_char CHAR(1) default 'x', my_null_text TEXT default null"
        sql += ", my_real REAL default 123.456, my_double DOUBLE PRECISION default 456.789"
        // sql += ", row_to_json(row(1,'foo'))"
        sql += ", my_date DATE default (now() at time zone 'utc')"
        sql += ", my_ts TIMESTAMP default (now() at time zone 'utc')"
        sql += ");"
        guard let _ = try? db.query(sql) else {
            XCTFail("_ should not be nil")
            return
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEmptyQueryStatement() {
        XCTAssertThrowsError(try conn?.query(""))
    }

    func testInvalidQueryStatement() {
        XCTAssertThrowsError(
            // comma is missing
            try conn?.query("CREATE TABLE IF NOT EXISTS rope(id SERIAL PRIMARY KEY name TEXT))")
        )
    }

    func testBasicQueryStatement() {
        // the following SQL should always work, even on empty databases
        //let res = try! conn!.query("SELECT version();")
        //XCTAssertNotNil(res)
        guard let _ = try? conn?.query("SELECT version();") else {
            XCTFail("_ should not be nil")
            return
        }
    }

    func testQueryInsertStatement() {
        guard let res = try? conn?.query("INSERT INTO rope (my_text) VALUES('Rope is awesome!')") else {
            XCTFail("res should not be nil")
            return
        }
        XCTAssertEqual(res?.rows().count, 0)
    }

    func testReadmeExample() {
        // test the code displayed in the README example
        guard let conn = conn else {
            XCTFail("conn should not be nil")
            return
        }

        // run queries
        guard let _ = try? conn.query("INSERT INTO rope (my_text) VALUES('Readme works')") else {
            XCTFail("_ should not be nil")
            return
        }
        guard let res = try? conn.query("SELECT * FROM rope") else {
            XCTFail("res should not be nil")
            return
        }
        XCTAssertNotNil(res?.rows())

        // turn result into 2-dimensional array
        if let rows = res?.rows() {
            for row in rows {
                // convert values into Swift types
                let id = row["id"] as? Int
                let myText = row["my_text"] as? String
                XCTAssertEqual(id, 1)
                XCTAssertEqual(myText, "Readme works")
            }
        }
    }

    func testQuerySelectRowStringTypes() {
        guard let rows = insertAndSelectTestRows() else {
            XCTFail("rows should not be nil")
            return
        }
        XCTAssertEqual(rows.count, 2)

        // text to string
        let myText = rows[0]["my_text"] as? String
        XCTAssertEqual(myText!, "Rope is dope!")

        // varchar to string
        let myVarchar = rows[0]["my_varchar"] as? String
        XCTAssertEqual(myVarchar!, "abc")

        // char to string
        let myChar = rows[0]["my_char"] as? String
        XCTAssertEqual(myChar!, "x")

        // null value of text to string
        let myNullText = rows[0]["my_null_text"] as? String
        XCTAssertEqual(myNullText, nil)
    }

    func testQuerySelectRowNumericTypes() {
        guard let rows = insertAndSelectTestRows() else {
            XCTFail("rows should not be nil")
            return
        }
        XCTAssertEqual(rows.count, 2)

        let id = rows[0]["id"] as? Int
        XCTAssertEqual(id!, 2)

        // check if order is correct
        let idNextRow = rows[1]["id"] as? Int
        XCTAssertEqual(idNextRow!, 1)

        // real to float
        let myReal = rows[0]["my_real"] as? Float
        XCTAssertEqual(myReal!, 123.456)

        // double to float
        let myDouble = rows[0]["my_double"] as? Float
        XCTAssertEqual(myDouble!, 456.789)

        // conversion from integer to string returns nil
        let idString = rows[0]["id"] as? String
        XCTAssertNil(idString)

        // a non-existing column is nil
        let idx = rows[0]["xid"] as? Int
        XCTAssertNil(idx)
    }

    func testQuerySelectRowDateTypes() {
        guard let rows = insertAndSelectTestRows() else {
            XCTFail("rows should not be nil")
            return
        }
        XCTAssertEqual(rows.count, 2)

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

        // timestamp to Date
        let myTS = rows[0]["my_ts"] as? Date
        XCTAssertNotNil(myTS)

        // date to Date
        let myDate = rows[0]["my_date"] as? Date
        XCTAssertNotNil(myDate)

        // check if date (is 0:00) and timestamp are correct are correct
        let now = Date()
        XCTAssertEqual(
            formatDate(myTS!, format: "YYY-mm-dd HH:mm"), formatDate(now, format: "YYY-mm-dd HH:mm")
        )

        let myDateDay = Calendar.current.component(.day, from: myDate!)
        let nowDay = Calendar.current.component(.day, from: now)
        XCTAssertEqual(myDateDay, nowDay)

        // conversion from integer to string returns nil
        let idString = rows[0]["id"] as? String
        XCTAssertNil(idString)

        // a non-existing column is nil
        let idx = rows[0]["xid"] as? Int
        XCTAssertNil(idx)
    }

    /// helper function which tests the connection and
    /// inserts two rows to test defaults & type conversion
    /// returns the optional rows, nil on error
    func insertAndSelectTestRows() -> [[String: Any?]]? {
        guard let conn = conn else {
            XCTFail("conn should not be nil")
            return nil
        }

        // insert 2 rows
        guard let _ = try? conn.query("INSERT INTO rope (my_text) VALUES('Rope is awesome!')") else {
            XCTFail("_ should not be nil")
            return nil
        }
        guard let _ = try? conn.query("INSERT INTO rope (my_text) VALUES('Rope is dope!')") else {
            XCTFail("_ should not be nil")
            return nil
        }

        // select the rows
        guard let res = try? conn.query("SELECT * FROM rope ORDER BY id DESC") else {
            XCTFail("res should not be nil")
            return nil
        }
        return res?.rows()
    }
}

// Helper methods

fileprivate let formatter = DateFormatter()

/// returns a formatted date string of a given date
/// on default it uses the abbreviated timezone "UTC"
fileprivate func formatDate(_ date: Date, format: String, timezone: String = "UTC") -> String {
    let formatter = DateFormatter()

    if !timezone.isEmpty {
        formatter.timeZone = TimeZone(abbreviation: timezone)
    }
    formatter.dateFormat = format

    let dateStr = formatter.string(from: date)
    return dateStr
}
