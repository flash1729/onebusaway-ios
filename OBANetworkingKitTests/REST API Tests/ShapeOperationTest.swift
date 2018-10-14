//
//  ShapeOperationTest.swift
//  OBANetworkingKitTests
//
//  Created by Aaron Brethorst on 10/6/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import XCTest
import Nimble
import OHHTTPStubs
@testable import OBANetworkingKit

class ShapeOperationTest: OBATestCase {
    let shapeID = "1_20010002"

    func testShapeAPIPath() {
        expect(ShapeOperation.buildAPIPath(shapeID: self.shapeID)) == "/api/where/shape/\(shapeID).json"
    }

    func testSuccessfulShapeRequest() {
        let apiPath = ShapeOperation.buildAPIPath(shapeID: shapeID)

        stub(condition: isHost(self.host) && isPath(apiPath)) { _ in
            return self.JSONFile(named: "shape_1_20010002.json")
        }

        waitUntil { done in
            self.builder.getShape(id: self.shapeID) { op in
                expect(op.entries).toNot(beNil())
                expect(op.references).toNot(beNil())

                let entry = op.entries!.first!
                expect(entry["length"] as? Int) == 65

                done()
            }
        }
    }
}
