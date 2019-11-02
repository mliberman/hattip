import XCTest

import httpTests

var tests = [XCTestCaseEntry]()
tests += httpTests.allTests()
XCTMain(tests)
