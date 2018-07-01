//
//  VacuumWorld.swift
//  AImaKit
//
//  Created by Dave King on 6/28/18.
//

import Foundation

public enum Location {
  case left, right
  static func random() -> Location {
    return Bool.random() ? .left : .right
  }
}

public enum LocationState {
  case clean, dirty
}

/**
 * A Percept for the simple vacuum environment and its agents.
 */
//public enum LocalVacuumPercept: Percept {
//  case leftClean, leftDirty, rightClean, rightDirty
//  public func isDirty() -> Bool { return self == .leftDirty || self == .rightDirty }
//  public func isLeft() -> Bool { return self == .leftClean || self == .leftDirty }
//  public func isRight() -> Bool { return !isLeft() }
//}
public struct LocalVacuumPercept: Percept {
  var location: Location
  var state: LocationState
  public init(location: Location, state: LocationState) {
    self.location = location
    self.state = state
  }
}

/**
 * Artificial Intelligence A Modern Approach (3rd Edition): Figure 2.8, page 48.
 *
 * ```
 * function REFLEX-VACUUM-AGENT([location, status]) returns an action
 *   if status = Dirty then return Suck
 *   else if location = A then return Right
 *   else if location = B then return Left
 * ```
 *
 * Figure 2.8: The agent program for a simple reflex agent in the two-state
 * vacuum environment. This program implements the action function tabulated
 * in Figure 2.3.
 *
 * Documentation care of Ciaran O'Reilly.
 */
public class ReflexVacuumAgent: Agent {
  // Swift: The python solutions, where ReflexVacuumAgent() is just a function
  // (also referred to as a "factory") that returns an Agent initialized with the
  // ReflexVacuumAgentProgram, is simple and appealing.  On the downside, it means
  // the actual type is not easily displayed in trackers or tests, everyone is just
  // another Agent!  This could be especially confusing in tests that compare
  // performance of different agent types.  With that in mind, we use real types,
  // like the java solution.

  public init() {
    super.init({ (_ scene: Percept) -> Action in
      guard let percept = scene as? LocalVacuumPercept else {
        fatalError("Expected LocalVacuumPercept, got \(scene), aborting.")
      }
      if percept.state == .dirty {
        return .suck
      }
      return percept.location == .left ? .moveRight : .moveLeft;
    })
  }

}

/*
 * An actual environment!
 */
public class VacuumEnvironment: Environment {

  var locationState: [Location: LocationState]

  /// Initialize a vacuum environment.
  ///
  /// - Parameters:
  ///   - leftState: `LocationState` (.clean or .dirty) of left position.
  ///   - rightState: `LocationState` of right position.
  public init(_ leftState: LocationState, _ rightState: LocationState) {
    locationState = [.left: leftState, .right: rightState]
  }

  public override func executeAction(_ agent: Agent, _ action: Action) -> Void {
    guard let position = envObjects[agent] else {
      fatalError("Attempt to execute action for nonexistent agent \(agent).")
    }
    switch action {
      case .suck:
        locationState[position] = .clean
      case .moveLeft:
        envObjects[agent] = .left
      case .moveRight:
        envObjects[agent] = .right
      default:
        fatalError("Invalid agent action \(action).")
    }
  }

  public override func getPerceptSeenBy(_ agent: Agent) -> Percept {
    guard let position = envObjects[agent] else {
      fatalError("Attempt to retrieve percept for nonexistent agent \(agent).")
    }
    return LocalVacuumPercept(location: position, state: locationState[position]!)
  }

}
