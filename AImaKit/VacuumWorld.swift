//
//  VacuumWorld.swift
//  AImaKit
//
//  Created by Dave King on 6/28/18.
//

import Foundation

// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  VACUUM WORLD  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

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

  // Setup notation for clear statements of the left-right world
  // for agents and applications that use it.
  public static let left = [0], right = [1] // One dimensional space.
  public enum LocationState { case clean, dirty }
  
  // Simplify / clarify a common type. Got stuff?
  public typealias Stuff = Set<EnvironmentObject>

  /**
   * `Dirt` is an `EnvironmentObject` in the `VacuumWorld`.
   */
  public class Dirt: EnvironmentObject { // Dirt is uncountable?  Dirt() == Dirt()?
    
  }

  /**
   * What an `Agent` can do.
   */
  public enum AgentAction: String, IAction {
    case suck, moveLeft, moveRight
    public func getValue() -> String { return self.rawValue }
  }

  /**
   * What an `Environment` can do.
   */
  public enum EnvironmentAction: String, IAction {
    case noOp, moveAgent, removeDirt
    public func getValue() -> String { return self.rawValue }
  }

  /**
   * What an `Agent` sees.
   */
  public struct AgentPercept: IPercept, Hashable {
    private(set) public var location: Location
    private(set) public var objects: Stuff

    // Override default internal access level for memberwise initializer.
    public init(location: Location, objects: Stuff) {
      self.location = location
      self.objects = objects
    }
  }
  
  /**
   * What a `Judge` sees.
   */
  public struct JudgePercept: IPercept, Hashable {
    let action: EnvironmentAction
    let location: Location // Location _after_ action taken.
  }
  
  public typealias Changes = [JudgePercept]

//  public struct JudgePercept: IPercept, Hashable {
//    private(set) public var location: Location
//    private(set) public var objects: Stuff
//
//    // Override default internal access level for memberwise initializer.
//    public init(location: Location, objects: Stuff) {
//      self.location = location
//      self.objects = objects
//    }
//
//  }


  // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
  // --- ENVIRONMENTS ---
  // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

  /**
   * The `VacuumWorld` environment.
   */
  public class Environment: IEnvironment {

    /**
     * Initialize a `VacuumEnvironment` with the given `Space`.
     *
     * - Parameter space: The space to use for this environment.
     */
    public override init(_ space: Space) {
      super.init(space)
    }

    public override func executeAction(_ agent: IAgent, _ anAction: IAction) -> [IPercept] {
      guard let action = anAction as? AgentAction else {
        fatalError("Expected VacuumWorld.AgentAction, got \(anAction).  Aborting")
      }
      guard let agentLocation = envObjects[agent] else {
        fatalError("Attempt to execute action for nonexistent agent \(agent).")
      }
      var changes = [JudgePercept]()
      switch action {
        case .suck: // Vacuum away all dirt from agent's location.
          let newDictionary = envObjects.filter() { element -> Bool in
            let (object, location) = element
            return location != agentLocation || type(of: object) != Dirt.self
          }
          envObjects = newDictionary
          changes.append(JudgePercept(action: .removeDirt, location: agentLocation))
        case .moveLeft:
          let newLocation = [agentLocation[0] - 1] + agentLocation[1...]
          if space.contains(newLocation) {
            envObjects[agent] = newLocation
            changes.append(JudgePercept(action: .moveAgent, location: newLocation))
          } else {
            changes.append(JudgePercept(action: .noOp, location: agentLocation))
          }
        case .moveRight:
          let newLocation = [agentLocation[0] + 1] + agentLocation[1...]
          if space.contains(newLocation) {
            envObjects[agent] = newLocation
            changes.append(JudgePercept(action: .moveAgent, location: newLocation))
          } else {
            changes.append(JudgePercept(action: .noOp, location: agentLocation))
          }
      } // End switch.
      return changes
    }
    
    public override func getPerceptSeenBy(_ agent: IAgent) -> IPercept {
      guard let agentLocation = envObjects[agent] else {
        fatalError("Attempt to retrieve percept for nonexistent agent \(agent).")
      }
      let stuff = Set(getObjects(at: agentLocation).keys)
      return AgentPercept(location: agentLocation, objects: stuff)
    }
  }


  // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
  // --- AGENTS ---
  // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

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
   * This reflex agent _function_ may be implemented with a table-based,
   * rule-based, or simple handwritten _program_.  It is only when we go
   * to model-based, where state or memory is added, that the agent gets
   * scary smart (or at least noticably smarter).
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
      super.init({ (_ scene: IPercept) -> AgentAction in
      
        guard let percept = scene as? AgentPercept else {
          fatalError("Expected VacuumWorld.AgentPercept, got \(scene), aborting.")
        }

        precondition(percept.location == left || percept.location == right)
        
        let isDirty = percept.objects.contains(where: { type(of: $0) == Dirt.self } )
        let state: LocationState = isDirty ? .dirty : .clean
        
        if ruleBased  // Rule-based flavor uses dictionary of dictionaries.
        {
          let rules: [Location: [LocationState: AgentAction]] = [
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
      }) // End agent program.
    }
  } // End ReflexAgent.


  // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
  // --- JUDGES ---
  // ****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

  /**
   * Like `ReflexAgent`, `ReflexJudge` has no state (no memory) and returns
   * a score based solely on the last change to the environment.
   */
  public class ReflexJudge: IJudge {
    /**
     * Initialize a ReflexJudge instance with a move(-1), suck(+10) program.
     */
    public init() {
      super.init({ (_ scene: IPercept) -> Double in
        print("\nIN JUDGE WITH PERCEPT \(scene)\n")
        guard let percept = scene as? JudgePercept else {
          fatalError("Expected VacuumWorld.JudgePercept, got \(scene), aborting.")
        }
        var score = 0.0
        switch percept.action {
          case .noOp:
            score = 0.0 // Is agent smart or did it just bump into a wall?
          case .moveAgent:
            score = -1
          case .removeDirt:
            score = +10
        }
        return score
      }) // End judge program.
    } // End ReflexJudge initializer.
  } // End ReflexJudge.
} // End VacuumWorld namespace.
