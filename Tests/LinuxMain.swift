// Generated using Sourcery 0.5.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// LinuxMain.stencil is a template ripped from Sourcery's main codebase that autogenerates the XCTMain call for us!
import XCTest
@testable import RopeTests

extension RopeConnectionTests {
  static var allTests = [
    ("testConnectWithParams", testConnectWithParams),
    ("testConnectWithStruct", testConnectWithStruct),
  ]
}

extension RopeQueryJSONTests {
  static var allTests = [
    ("testQueryInsertStatement", testQueryInsertStatement),
    ("testQuerySelectStatement", testQuerySelectStatement),
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

XCTMain([
  testCase(RopeConnectionTests.allTests),
  testCase(RopeQueryJSONTests.allTests),
  testCase(RopeQueryTests.allTests),
])
