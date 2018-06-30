//
//  Agents.swift
//  AIma
//
//  Created by Dave King on 6/23/18.
//

import Foundation

// ////////////////////////////////////////////////////////////////////////////

/**
 * Describes an Action that can or has been taken by an Agent via one of its
 * Actuators.
 */
public enum Action: String {
  case noOp, suck, moveLeft, moveRight, moveUp, moveDown, etc
}

// ////////////////////////////////////////////////////////////////////////////

/**
 * Artificial Intelligence A Modern Approach (3rd Edition): pg 35.
 *
 * An agent's behavior is described by the 'agent function' that maps any given
 * percept sequence to an action. Internally, the agent function for an
 * artificial agent will be implemented by an agent program.
 *
 * - Parameter percept: The current percept of a sequence perceived by the Agent.
 * - Returns: The Action to be taken in response to the currently perceived percept.
 */
public typealias AgentProgram = (_ percept: Percept) -> Action
//
// Swift: That says AgentProgram is a function type that takes a Percept
// and returns an Action.
//

// ////////////////////////////////////////////////////////////////////////////

/**
 * Artificial Intelligence A Modern Approach (3rd Edition): Figure 2.1, page 35.
 *
 * Agents interact with environments through sensors and actuators.
 */
public class Agent: EnvironmentObject {
  /**
   * The *agent function* that maps percepts to actions.
   */
  public let execute: AgentProgram

  /**
   * Life-cycle indicator as to the liveness of an Agent.
   */
  internal(set) public var isAlive = true
  
  /**
   * Custom initializer sets AgentProgram for this agent.  If no AgentProgram
   * is provided, a default program that always returns `Action.noOp` is used.
   * NOOP means "no operation" or "do nothing."
   *
   * - Parameter program: The agent's program.
   */
  public init(_ program: @escaping AgentProgram = { _ in return .noOp }) {
    execute = program
  }
}

// ////////////////////////////////////////////////////////////////////////////

/**
 * An `EnvironmentObject` can be added to an `Environment`.
 */
public class EnvironmentObject: Object {
  // Not clear this distinction is needed (yet) but there it is.
  // It seems Percept must be a protocol if we want to tag enums with it...
}

// ////////////////////////////////////////////////////////////////////////////

/**
 * Superclass for a hierarchy of observers and trackers to view the interaction
 * of Agent(s) with an Environment.  Subclasses must override default NOOP
 * implementations with desired behavior.
 */
public class EnvironmentView: EnvironmentObject {
  /**
   * A simple notification message from an object in the Environment.
   *
   * - Parameter message: The message received.
   */
  public func notify(_ message: String) -> Void {
  
  }

  /**
   * Indicates an Agent has been added to the environment and what it
   * perceives initially.
   *
   * - Parameter agent: The Agent just added to the Environment.
   * - Parameter source: The Environment to which the agent was added.
   */
  public func agentAdded(_ agent: Agent, _ source: Environment) -> Void {
  
  }

  /**
   * Indicates the Environment has changed as a result of an Agent's action.
   *
   * - Parameter agent: The Agent that performed the Action.
   * - Parameter percept: The Percept the Agent received from the environment.
   * - Parameter action: The Action the Agent performed.
   * - Parameter source: The Environment in which the agent has acted.
   */
  public func agentActed
    (_ agent: Agent, _ percept: Percept, _ action: Action, _ source: Environment) -> Void
  {
  
  }
}

// ////////////////////////////////////////////////////////////////////////////

/**
 * Artificial Intelligence A Modern Approach (3rd Edition): pg 34.
 *
 * We use the term percept to refer the agent's perceptual inputs at any given
 * instant.
 */
public protocol Percept {

}

// ////////////////////////////////////////////////////////////////////////////

/**
 * Named in honor of Java's `Object`, this superclass provides a default
 * equivalence relation and hash code for any Swift types you want to use
 * in a `Collection` (like `Array` or `Set`).  Subclasses may override
 * default implementations if necessary.
 */
public class Object: Hashable {

  // Explicitly increase access level from default 'internal' to 'public'.
  public init() {
  
  }
  
  // Two object or instance references are equal if and only if they point to
  // the same address, the same memory.
  public static func == (lhs: Object, rhs: Object) -> Bool {
    return lhs === rhs
  }
  
  // These hash values also use address-like discrimination.
  public var hashValue: Int { return ObjectIdentifier(self).hashValue }
}

// ////////////////////////////////////////////////////////////////////////////

/**
 * Top of the `Environment` hierarchy, instances of this class will crash like
 * the Python examples since Swift lacks proper abstract classes.  So subclass
 * this for your particular Task Environment and override the crashers with
 * appropriate behavior.
 */
public class Environment {
  var envObjects = Dictionary<EnvironmentObject, Location>()
  var agents = Set<Agent>()
  var views = Set<EnvironmentView>()
  var performanceMeasures: [Agent: Double] = [:]

  //
  // PUBLIC METHODS
  //
  
  //
  // Methods to be implemented by subclasses.

  public func executeAction(_: Agent, _: Action) -> Void {
    fatalError("World is not a complete Environment; subclasses must override this method.")
  }

  public func getPerceptSeenBy(_: Agent) -> Percept {
    fatalError("World is not a complete Environment; subclasses must override this method.")
  }

//  /**
//   * Method for implementing dynamic environments in which not all changes are
//   * directly caused by agent action execution. The default implementation
//   * does nothing.
//   */
//  public void createExogenousChange() {
//  }

  //
  // START-Environment
  public func getAgents() -> Set<Agent> {
    let copy = agents
    return copy
  }

  public func getEnvironmentObjects() -> Dictionary<EnvironmentObject, Location> {
    let copy = envObjects
    return copy
  }

  public func addEnvironmentObject(_ thing: EnvironmentObject, at location: Location?) -> Void {
    if envObjects.keys.contains(thing) {
      return // There is only one of each Object.
    }
    let position = location ?? Location.random()
    envObjects[thing] = position
    if let agent = thing as? Agent {
      agents.insert(agent)
      performanceMeasures[agent] = 0.0
      // notifyEnvironmentViews(agent);
    }
  }

  public func removeEnvironmentObject(_ thing: EnvironmentObject) -> Void {
    envObjects[thing] = nil
    if let agent = thing as? Agent {
      performanceMeasures.removeValue(forKey: agent)
      agents.remove(agent);
    }
  }

//  /**
//   * Central template method for controlling agent simulation. The concrete
//   * behavior is determined by the primitive operations
//   * {@link #getPerceptSeenBy(Agent)}, {@link #executeAction(Agent, Action)},
//   * and {@link #createExogenousChange()}.
//   */
  public func step() -> Void {
    for agent in agents {
      if agent.isAlive {
        let percept = getPerceptSeenBy(agent)
        let action = agent.execute(percept)
        executeAction(agent, action);
        notifyEnvironmentViews(agent, percept, action);
      }
    }
//    createExogenousChange();
  }

  public func step(_ count: Int) -> Void {
    for _ in 1...count {
      step();
    }
  }

  public func stepUntilDone() -> Void {
    while !isDone() {
      step();
    }
  }

  public func isDone() -> Bool {
    for agent in agents {
      if agent.isAlive {
        return false
      }
    }
    return true;
  }

  public func getPerformanceMeasure(forAgent: Agent) -> Double? {
    return performanceMeasures[forAgent]
  }

  func updatePerformanceMeasure(forAgent: Agent, addTo: Double) -> Void {
    if performanceMeasures[forAgent] != nil {
      performanceMeasures[forAgent]! += addTo
    }
  }

  public func addEnvironmentView(_ view: EnvironmentView) ->Void {
    views.insert(view)
  }

  public func removeEnvironmentView(_ view: EnvironmentView) -> Void {
    views.remove(view);
  }

  public func notifyViews(_ message: String) -> Void {
    for view in views {
      view.notify(message);
    }
  }

  // END-Environment
  //

  //
  // PROTECTED METHODS
  //

  func notifyEnvironmentViews(_ agent: Agent) -> Void {
    for view in views {
      view.agentAdded(agent, self);
    }
  }

  func notifyEnvironmentViews(_ agent: Agent, _ percept: Percept, _ action: Action) -> Void {
    for view in views {
      view.agentActed(agent, percept, action, self);
    }
  }

}
