//
//  VacuumWorld.swift
//  AImaKit
//
//  Created by Dave King on 6/28/18.
//

import Foundation

/**
 * Artificial Intelligence A Modern Approach (3rd Edition): pg 58.
 *
 * Let the world contain just two locations. Each location may or may not
 * contain dirt, and the agent may be in one location or the other. There are 8
 * possible world states, as shown in Figure 3.2. The agent has three possible
 * actions in this version of the vacuum world: `Left`, `Right`, and `Suck`.
 * Assume for the moment, that sucking is 100% effective. The goal is to
 * clean up all the dirt.
 */
public class VacuumWorld { // Begin VacuumWorld namespace.

  /**
   * Actuator requirements for the simple vacuum environment and its agents.
   */
  public enum Action: String, IAction {
    case suck, moveLeft, moveRight
    public func getValue() -> String { return self.rawValue }
  }

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
   * Sensor requirements for the simple vacuum environment and its agents.
   *
   * Swift: Note that `Percept` is _not_ an `Object` so its equivalence relation
   * and hash code are not based strictly on instance address like `Object`s; rather,
   * we let the compiler provide `Equatable` and `Hashable` implementations
   * automatically, based on the equatable and hashable members of `Percept`,
   * but the Swift compiler (evidently) won't do this for us unless we explicitly
   * request `Hashable` in the definition.  OK?
   */
  public struct Percept: IPercept, Hashable {
    var location: Location
    var state: LocationState
    public init(location: Location, state: LocationState) {
      self.location = location
      self.state = state
    }
  }

  /**
   * The VacuumWorld environment.
   */
  public class Environment: IEnvironment {

    var locationState: [Location: LocationState]

    /// Initialize a vacuum environment.
    ///
    /// - Parameters:
    ///   - leftState: `LocationState` (.clean or .dirty) of left position.
    ///   - rightState: `LocationState` of right position.
    public init(_ leftState: LocationState, _ rightState: LocationState) {
      locationState = [.left: leftState, .right: rightState]
    }

    public override func executeAction(_ agent: IAgent, _ anAction: IAction) -> Void {
      guard let action = anAction as? Action else {
        fatalError("Expected VacuumWorld.Action, got \(anAction).  Aborting")
      }
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
      }
    }

    public override func getPerceptSeenBy(_ agent: IAgent) -> IPercept {
      guard let position = envObjects[agent] else {
        fatalError("Attempt to retrieve percept for nonexistent agent \(agent).")
      }
      return Percept(location: position, state: locationState[position]!)
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
  public class ReflexAgent: IAgent {
    // Swift: The python solutions, where ReflexVacuumAgent() is just a function
    // (also referred to as a "factory") that returns an Agent initialized with the
    // ReflexVacuumAgentProgram, is simple and appealing.  On the downside, it means
    // the actual type is not easily displayed in trackers or tests, everyone is just
    // another Agent!  This could be especially confusing in tests that compare
    // performance of different agent types.  With that in mind, we use real types,
    // like the java solution.

    /**
     * Initialize a ReflexAgent instance with the REFLEX-VACUUM-AGENT program.
     */
    public init(ruleBased: Bool = false) {
      super.init({ (_ scene: IPercept) -> Action in
        guard let percept = scene as? Percept else {
          fatalError("Expected VacuumWorld.Percept, got \(scene), aborting.")
        }
        if ruleBased  // Rule-based flavor.
        {
          let rules: [Percept: Action] = [
            Percept(location: .left, state: .clean): .moveRight,
            Percept(location: .left, state: .dirty): .suck,
            Percept(location: .right, state: .clean): .moveLeft,
            Percept(location: .right, state: .dirty): .suck,
          ]
          return rules[percept]! // Prove this is safe.
        }
        else          // Algorithm-based variation.
        {
          if percept.state == .dirty {
            return .suck
          }
          return percept.location == .left ? .moveRight : .moveLeft;
        }
      })
    }

  }


} // End VacuumWorld namespace.
