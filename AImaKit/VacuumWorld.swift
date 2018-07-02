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
public class VacuumWorld { // Begin VacuumWorld task environment.

  /**
   * Actuator requirements for the simple vacuum environment and its agents.
   */
  public enum Action: String, IAction {
    case suck, moveLeft, moveRight
    public func getValue() -> String { return self.rawValue }
  }

  // Setup notation for clear statements of the left-right world
  // for agents and applications that use it.
  public static let left = [0], right = [1] // Those are 1D locations.
  public enum LocationState { case clean, dirty }

  // Simplify / clarify a common type. Got stuff?
  typealias Stuff = Set<EnvironmentObject>

  /**
   * Sensor requirements for the simple vacuum environment and its agents.
   */
  public struct Percept: IPercept, Hashable {
    var location: Location
    var objects: Stuff
  }

  /**
   * The VacuumWorld environment.
   */
  public class Environment: IEnvironment {

    // var locationState: [Location: LocationState]

    /**
     * Initialize a `VacuumEnvironment` with the given `Space`.
     *
     * - Parameter space: The space to use for this environment.
     */
    public init(_ space: Space) {
      super.init()
      self.space = space
    }

    public override func executeAction(_ agent: IAgent, _ anAction: IAction) {
      guard let action = anAction as? Action else {
        fatalError("Expected VacuumWorld.Action, got \(anAction).  Aborting")
      }
      guard let agentLocation = envObjects[agent] else {
        fatalError("Attempt to execute action for nonexistent agent \(agent).")
      }
      switch action {
        case .suck: // Vacuum away all dirt from agent's location.
          let newDictionary = envObjects.filter() { element -> Bool in
            let (object, location) = element
            return location != agentLocation || type(of: object) != Dirt.self
          }
          envObjects = newDictionary
        case .moveLeft:
          let newLocation = [agentLocation[0] - 1] + agentLocation[1...]
          if space.contains(newLocation) {
            envObjects[agent] = newLocation
          }
        case .moveRight:
          let newLocation = [agentLocation[0] + 1] + agentLocation[1...]
          if space.contains(newLocation) {
            envObjects[agent] = newLocation
          }
      }
    }
    
    public override func getPerceptSeenBy(_ agent: IAgent) -> IPercept {
      guard let agentLocation = envObjects[agent] else {
        fatalError("Attempt to retrieve percept for nonexistent agent \(agent).")
      }
      let things = Set(getEnvironmentObjects(at: agentLocation).keys)
      return Percept(location: agentLocation, objects: things)
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

        precondition(percept.location == left || percept.location == right)
        
        let isDirty = percept.objects.contains(where: { type(of: $0) == Dirt.self } )
        let state: LocationState = isDirty ? .dirty : .clean
        
        if ruleBased  // Rule-based flavor.
        {
          let rules: [Location: [LocationState: Action]] = [
            left:  [.clean: .moveRight],
            left:  [.dirty: .suck],
            right: [.clean: .moveLeft],
            right: [.dirty: .suck],
          ]
          return rules[percept.location]![state]!
        }
        else          // Algorithm-based variation.
        {
          if isDirty {
            return .suck
          }
          return percept.location == left ? .moveRight : .moveLeft;
        }
      })
    }
  }
} // End VacuumWorld namespace.
