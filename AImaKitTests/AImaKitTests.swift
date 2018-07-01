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
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    typealias VW = VacuumWorld

    func run(_ leftState: VW.LocationState, _ rightState: VW.LocationState,
             _ location: VW.Location, _ steps: Int = 8) -> String
    {
      let environment = VW.Environment(leftState, rightState)
      let agent = VW.ReflexAgent()
      environment.addEnvironmentObject(agent, at: location)
      let view = SimpleActionTracker()
      environment.addEnvironmentView(view)
      environment.step(steps)
      return view.getActions()
    }

    var result = run(.clean, .clean, .left)
    print("(.clean, .clean, .left) -> \(result)")
    XCTAssert(result ==
      "moveRight, moveLeft, moveRight, moveLeft, moveRight, moveLeft, moveRight, moveLeft")

    result = run(.clean, .dirty, .left)
    print("(.clean, .dirty, .left) -> \(result)")
    XCTAssert(result ==
      "moveRight, suck, moveLeft, moveRight, moveLeft, moveRight, moveLeft, moveRight")

    result = run(.dirty, .clean, .right)
    print("(.dirty, .clean, .right) -> \(result)")
    XCTAssert(result ==
      "moveLeft, suck, moveRight, moveLeft, moveRight, moveLeft, moveRight, moveLeft")

    result = run(.dirty, .dirty, .right)
    print("(.dirty, .dirty, .right) -> \(result)")
    XCTAssert(result ==
      "suck, moveLeft, suck, moveRight, moveLeft, moveRight, moveLeft, moveRight")
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
