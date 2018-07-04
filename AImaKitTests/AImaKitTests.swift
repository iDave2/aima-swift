//
//  AImaKitTests.swift
//  AImaKitTests
//
//  Created by Dave King on 6/23/18.
//

import XCTest
@testable import AImaKit

class AImaKitTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testReflexVacuumAgent() {
    
    typealias VW = VacuumWorld

    func run(_ leftState:     VW.LocationState,
             _ rightState:    VW.LocationState,
             _ agentLocation: Location,
             _ ruleBased:     Bool = false,
             _ steps:         Int = 7
            ) -> String
    {
      let environment = VW.Environment(Space(0..<2)) // Two locations, left and right.
      let agent = VW.ReflexAgent()
      environment.addObject(agent, at: agentLocation)
      if leftState == .dirty {
        environment.addObject(VW.Dirt(), at: VW.left)
      }
      if rightState == .dirty {
        environment.addObject(VW.Dirt(), at: VW.right)
      }
      let view = SimpleActionTracker()
      environment.addEnvironmentView(view)
      environment.step(steps)
      return view.getActions()
    }

    var result = run(.clean, .clean, VW.left)
    print("(.clean, .clean, VW.left) -> \(result)")
    XCTAssert(result == "moveRight, moveLeft, moveRight, moveLeft, moveRight, moveLeft, moveRight")

    result = run(.clean, .dirty, VW.left, true)
    print("(.clean, .dirty, VW.left, true) -> \(result)")
    XCTAssert(result == "moveRight, suck, moveLeft, moveRight, moveLeft, moveRight, moveLeft")

    result = run(.dirty, .clean, VW.right, true)
    print("(.dirty, .clean, VW.right, true) -> \(result)")
    XCTAssert(result == "moveLeft, suck, moveRight, moveLeft, moveRight, moveLeft, moveRight")

    result = run(.dirty, .dirty, VW.right)
    print("(.dirty, .dirty, VW.right) -> \(result)")
    XCTAssert(result == "suck, moveLeft, suck, moveRight, moveLeft, moveRight, moveLeft")
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
