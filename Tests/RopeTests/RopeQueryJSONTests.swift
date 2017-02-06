import XCTest
import Rope

final class RopeQueryJSONTests: XCTestCase {
    let creds = TestCredentials.getCredentials()
    var conn: Rope? // auto-tested optional db connection
    
    override func setUp() {
        super.setUp()
        
        // create connection
        conn = try? Rope.connect(credentials: creds)
        XCTAssertNotNil(conn)
        
        guard let db = conn else { return }
        var res = try! db.query("DROP TABLE IF EXISTS json")
        XCTAssertNotNil(res)
        
        // create a table with different types as test, payload can be nil
        res = try! db.query("CREATE TABLE IF NOT EXISTS json (id SERIAL PRIMARY KEY,  json JSONB);")
        XCTAssertNotNil(res)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testQueryInsertStatement() {
        guard let res = try? conn?.query("INSERT INTO json (json) VALUES ('{\"due_in_seconds\":0,\"method\":\"POST\",\"headers\":{},\"url\":\"http://localhost\"}') RETURNING id;") else {
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
}
