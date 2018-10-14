//
//  OBATestCase.swift
//  OBANetworkingKitTests
//
//  Created by Aaron Brethorst on 10/14/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import XCTest
import OHHTTPStubs
import OBANetworkingKit

public class OBATestCase : XCTestCase, OperationTest {
    public override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
}
