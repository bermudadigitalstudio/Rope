import XCTest
import Rope

final class RopeQueryJSONTests: XCTestCase {
    let creds = TestCredentials.getCredentials()
    var conn: Rope? // auto-tested optional db connection

    let insertQuery = "INSERT INTO json (json) VALUES " +
                      "('{\"due_in_seconds\":0,\"method\":\"POST\",\"headers\":{},\"url\":\"http://localhost\"}') " +
                      "RETURNING id;"

    override func setUp() {
        super.setUp()

        // create connection
        conn = try? Rope.connect(credentials: creds)
        XCTAssertNotNil(conn)

        guard let dropRes = try? conn?.query("DROP TABLE IF EXISTS json") else {
            XCTFail("res should not be nil"); return
        }
        XCTAssertNotNil(dropRes)

        // create a table with different types as test, payload can be nil
        let sql = "CREATE TABLE IF NOT EXISTS json (id SERIAL PRIMARY KEY,  json JSONB);"
        guard let createRes = try? conn?.query(sql) else {
            XCTFail("res should not be nil"); return
        }
        XCTAssertNotNil(createRes)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testQueryInsertStatement() {
        guard let res = try? conn?.query(insertQuery) else {
            XCTFail("res should not be nil"); return
        }    
        XCTAssertEqual(res?.rows().count, 1)

        guard let row = res?.rows().first else {
            XCTFail("res should not be nil"); return
        }

        let id = row["id"] as? Int
        XCTAssertNotNil(id)
        XCTAssertEqual(id, 1)
    }

    func testQuerySelectStatement() {
        guard let _ = try? conn?.query(insertQuery),
            let select = try? conn?.query("SELECT *  FROM json")
        else {
            XCTFail("res should not be nil"); return
        }

        guard let row = select?.rows().first else {
            XCTFail("res should not be nil"); return
        }

        let payload = row["json"] as? [String: Any]
        XCTAssertNotNil(payload)

        guard let method = payload?["method"] as? String,
            let dueInSeconds = payload?["due_in_seconds"] as? Int,
            let urlString = payload?["url"] as? String
        else {
            XCTFail("res should not be nil"); return
        }

        XCTAssertEqual(urlString, "http://localhost")
        XCTAssertEqual(method, "POST")
        XCTAssertEqual(dueInSeconds, 0)
    }
}
