// Generated using Sourcery 0.5.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest
@testable import RopeTests

extension RopeConnectionTests {
  static var allTests = [
    ("testConnectWithParams", testConnectWithParams),
    ("testConnectWithStruct", testConnectWithStruct)
  ]
}

extension RopeQueryTests {
  static var allTests = [
    ("testEmptyQueryStatement", testEmptyQueryStatement),
    ("testInvalidQueryStatement", testInvalidQueryStatement),
    ("testBasicQueryStatement", testBasicQueryStatement),
    ("testQueryInsertStatement", testQueryInsertStatement),
    ("testReadmeExample", testReadmeExample),
    ("testQuerySelectRowStringTypes", testQuerySelectRowStringTypes),
    ("testQuerySelectRowNumericTypes", testQuerySelectRowNumericTypes),
    ("testQuerySelectRowDateTypes", testQuerySelectRowDateTypes)
  ]
}

extension RopeQueryJSONTests {
  static var allTests = [
    ("testQueryInsertStatement", testQueryInsertStatement)
  ]
}

XCTMain([
  testCase(RopeConnectionTests.allTests),
  testCase(RopeQueryTests.allTests),
  testCase(RopeQueryJSONTests.allTests)
])
