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
            ) -> (String, Double)
    {
      let environment = VW.Environment(Space(0..<2)) // Two locations, left and right.
      let agent = VW.ReflexAgent()
      let judge = VW.ReflexJudge()
      environment.addObject(agent, at: agentLocation)
      environment.addObject(judge) // Judges don't go on the gameboard.
      if leftState == .dirty {
        environment.addObject(VW.Dirt(), at: VW.left)
      }
      if rightState == .dirty {
        environment.addObject(VW.Dirt(), at: VW.right)
      }
      let view = SimpleActionTracker()
      environment.addEnvironmentView(view)
      environment.step(steps) // Run the simulation.
      var score = -10_000.0
      if let scores = environment.getScores(forAgent: agent) { // [IJudge: Double]?
        if scores.count > 0 && scores[judge] != nil {
          score = scores[judge]!
        }
      }
      return (view.getActions(), score)
    }
    
    print("")
    
    var scores: [Double] = []
    var sum = 0.0

    var (actions, score) = run(.clean, .clean, VW.left)
    scores.append(score); sum += score
    print("(.clean, .clean, VW.left) -> \(actions)")
    XCTAssert(actions == "moveRight, moveLeft, moveRight, moveLeft, moveRight, moveLeft, moveRight")

    (actions, score) = run(.clean, .dirty, VW.left, true)
    scores.append(score); sum += score
    print("(.clean, .dirty, VW.left, true) -> \(actions)")
    XCTAssert(actions == "moveRight, suck, moveLeft, moveRight, moveLeft, moveRight, moveLeft")

    (actions, score) = run(.dirty, .clean, VW.right, true)
    scores.append(score); sum += score
    print("(.dirty, .clean, VW.right, true) -> \(actions)")
    XCTAssert(actions == "moveLeft, suck, moveRight, moveLeft, moveRight, moveLeft, moveRight")

    (actions, score) = run(.dirty, .dirty, VW.right)
    scores.append(score); sum += score
    print("(.dirty, .dirty, VW.right) -> \(actions)")
    XCTAssert(actions == "suck, moveLeft, suck, moveRight, moveLeft, moveRight, moveLeft")
    
    print("Scores: \(scores), average:", sum / Double(scores.count))
    print("")
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
