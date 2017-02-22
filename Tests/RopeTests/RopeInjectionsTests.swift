import XCTest
import Rope
import Foundation

final class RopeInjectionTests: XCTestCase {
    
    let creds = TestCredentials.getCredentials()
    var conn: Rope?
    
    override func setUp() {
        super.setUp()
        
        guard let db = try? Rope.connect(credentials: creds) else {
            XCTFail("conn should not be nil")
            return
        }
        conn = db
    }
    
    func testSQLInjection() {
        let seedStatement = "CREATE TEMPORARY TABLE users(id SERIAL PRIMARY KEY, name text); "
        
        guard let _ = try? conn?.query(seedStatement),
            let _ = try? conn?.query("INSERT INTO users(name) VALUES ('Sebastian'),('Thomas'),('Johannes'),('Gabriel')") else {
                XCTFail("res should not be nil"); return
        }
        
        let maliciousInput = "lol'; INSERT INTO users(name) VALUES ('Black hat hacker') --"
        
        XCTAssertThrowsError(
            try conn?.query("SELECT * FROM users WHERE name = '\(maliciousInput)'")
        )
        
        func getLatestUserName() -> String? {
            guard let users = try? conn?.query("SELECT * FROM users") else {
                return nil
            }
            let latestUser = users?.rows().last?["name"] as? String
            return latestUser
        }
        
        XCTAssertNotEqual(getLatestUserName(), "Black hat hacker")
        
        // Reset and try again
        guard let _ = try? conn?.query("DISCARD TEMPORARY"),
            let _ = try? conn?.query(seedStatement),
            let _ = try? conn?.query("SELECT * FROM users WHERE name = $1", params: [maliciousInput]) else {
                XCTFail("res should not be nil"); return
        }
        
        XCTAssertNotEqual(getLatestUserName(), "Black hat hacker")
    }
    
    func testInjectionUsingStringInterpolation() {
        guard let _ = try? conn?.query("CREATE TEMPORARY TABLE another_injection_test(id SERIAL PRIMARY KEY, name text); "),
            let _ = try? conn?.query("INSERT INTO another_injection_test(name) VALUES ('Sebastian'),('Thomas'),('Johannes'),('Gabriel'),('moo'),('foo')") else {
                XCTFail("res should not be nil"); return
        }
        
        let injection = "foo' OR 1=1 OR name='moo"
        
        XCTAssertThrowsError(
            try conn?.query("SELECT * FROM another_injection_test WHERE name = '\(injection)'")
        )
    }
    
    func testStringInterpolation() {
        guard let _ = try? conn?.query("CREATE TEMPORARY TABLE string_interpolation_test(id SERIAL PRIMARY KEY, name text)"),
            let _ = try? conn?.query("INSERT INTO string_interpolation_test(name) VALUES ('Sebastian'),('Thomas'),('Johannes'),('Gabriel'),('Rope')") else {
                XCTFail("res should not be nil"); return
        }
        
        let name = "Rope"
        
        XCTAssertThrowsError(
            try conn?.query("SELECT * FROM string_interpolation_test WHERE name = '\(name)'")
        )
    }
}
