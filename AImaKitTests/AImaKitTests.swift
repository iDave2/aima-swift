//
//  AImaKitTests.swift
//  AImaKitTests
//
//  Created by Dave King on 6/23/18.
//

import XCTest
@testable import AImaKit

class AImaKitTests: XCTestCase {

    typealias VW = VacuumWorld
    typealias VWRunArgs = (Location, VW.LocationState, VW.LocationState, Bool)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of
        // each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of
        // each test method in the class.
        super.tearDown()
    }

    // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

    /**
     * Like the Swift Book example in Automatic Reference Counting chapter,
     * this test creates objects, deletes their reference, and print statements
     * in object's init() and deinit() tell us whether we have a leak.
     *
     * This immediately showed that our initial .instance solution is a leak
     * and confirms that the pattern,
     * ```
     * init() { // Does this fix the cycle or just hide it from compiler?
     *   super.init()                // Must do this before referencing self.
     *   execute = instanceProgram   // Now we can fix the pointer.
     * }
     * ```
     * just hides leak from compiler.
     *
     * Uncomment print statements in ModelBasedAgent.init and its super.init
     * to track whether beans are counted properly.
     */
    func testMemoryLeak() {
        var agent: VW.ModelBasedAgent?
        agent = VW.ModelBasedAgent() // Prints "initializing".
        if agent != nil { // Quiet compiler...
            agent = nil // Should print "deinitializing" if no memory leaks.
        }
        agent = VW.ModelBasedAgent()
        agent = nil
    }

    // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

    func testSpaceToArray() {
        print("\n*****  Testing space.toArray(repeating:)  *****")
        let space = EuclideanSpace(0..<3, 0..<2, 0..<1)
        guard let array = space.toArray(repeating: "unknown") as? [[[String]]] else {
            fatalError("Cannot construct array from space \(space).")
        }
        print("let array: [[[String]]] =", array)
    }

    // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

    func testVacuumWorld() {

        let tests: [VWRunArgs] = [
            (VW.left,  .clean, .clean, false),
            (VW.left,  .clean, .dirty, true),
            (VW.right, .dirty, .clean, true),
            (VW.right, .dirty, .dirty, false),
            ]

        let expectedReflexActions = [
            "moveRight, moveLeft, moveRight, moveLeft, moveRight, moveLeft, moveRight",
            "moveRight, suck, moveLeft, moveRight, moveLeft, moveRight, moveLeft",
            "moveLeft, suck, moveRight, moveLeft, moveRight, moveLeft, moveRight",
            "suck, moveLeft, suck, moveRight, moveLeft, moveRight, moveLeft",
            ]

        let expectedModelBasedActions = [
            "moveRight, noOp, noOp, noOp, noOp, noOp, noOp",
            "moveRight, suck, noOp, noOp, noOp, noOp, noOp",
            "moveLeft, suck, noOp, noOp, noOp, noOp, noOp",
            "suck, moveLeft, suck, noOp, noOp, noOp, noOp",
            ]

        runVacuumWorld(agentType: "ReflexAgent", tests: tests, results: expectedReflexActions)
        runVacuumWorld(agentType: "ModelBasedAgent", tests: tests, results: expectedModelBasedActions)

    }

    func runVacuumWorld(agentType: String, tests: [VWRunArgs], results: [String]) {

        func run(_ agentType:     String,
                 _ agentLocation: Location,
                 _ leftState:     VW.LocationState,
                 _ rightState:    VW.LocationState,
                 _ ruleBased:     Bool = false,
                 _ steps:         Int = 7
            ) -> (String, Double)
        {
            var environment = VW.Environment(EuclideanSpace(0..<2)) // Left and right.
            let agent = agentType == "ReflexAgent" ? VW.ReflexAgent() : VW.ModelBasedAgent()
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

        print("\n*****  Testing \(agentType)  *****")

        var scores: [Double] = []
        var sum = 0.0

        for i in 0..<tests.count {
            let (location, leftState, rightState, ruleBased) = tests[i]
            let (actions, score) = run(agentType, location, leftState, rightState, ruleBased)
            scores.append(score); sum += score
            var formatted = String(describing: tests[i]) // awkward
            formatted = formatted.replacingOccurrences(of: "AImaKitTests.VacuumWorld.LocationState", with: "")
            formatted = formatted.replacingOccurrences(of: "[0]", with: "left")
            formatted = formatted.replacingOccurrences(of: "[1]", with: "right")
            print("\(formatted) -> \(actions)")
            XCTAssert(actions == results[i]) // Silent unless it fails.
        }

        print("Scores: \(scores), average:", sum / Double(scores.count), "\n")
    }

    // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

}
