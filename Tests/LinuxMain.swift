import XCTest

import httpTests

var tests = [XCTestCaseEntry]()
tests += httpTests.__allTests()

XCTMain(tests)
