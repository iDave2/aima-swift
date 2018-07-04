//
//  Agents.swift
//  AImaKit
//
//  Created by Dave King on 6/23/18.
//
//  Should this earlier comment,
//
//  The notation `ISomeType` used in this file means that that type is meant
//  to be subclassed by actual `SomeType`s that satisfy requirements of a
//  particular task environment.
//
//  be replaced with this?
//
//  This top-level file contains global symbols prefixed with `AIma` so that
//  `AImaKit` symbols do not conflict with other frameworks like `UIKit`.
//

import Foundation


// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  AGENTS  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

/**
 * "An __agent__ is anything that can be viewed as perceiving its
 * __environment__ through __sensors__ and acting upon that environment
 * through __actuators__." -- AIMA3e, page 34.
 *
 * "When an agent is plunked down in an environment, it generates a sequence
 * of actions according to the percepts it receives. This sequence of actions
 * causes the environment to go through a sequence of states.  If the sequence
 * is _desirable_, then the agent has _performed well_.  This notion of
 * desirability is captured by a __performance measure__ that evaluates any
 * given sequence of environment states." -- AIMA3e, page 37, italics mine.
 *
 * __Exercise__
 *
 * A performance measure, or the program that implements it,
 * evaluates or _scores_ an agent's choices.  It is like a judge in a game.
 * Explain how this `Judge` is like or unlike the `Agent` defined above.
 */
//public class IAgent: EnvironmentObject {
//  /**
//   * The *agent function* that maps percepts to actions.
//   */
//  let execute: AgentProgram
//
//  /**
//   * Life-cycle indicator as to the liveness of an Agent.
//   */
//  var isAlive = true
//
//  /**
//   * Custom initializer sets AgentProgram for this agent.
//   *
//   * - Parameter program: The agent's program.
//   */
//  public init(_ program: @escaping AgentProgram) {
//    execute = program
//  }
//}

// ////////////////////////////////////////////////////////////////////////////

/**
 * "We use the term __percept__ to refer to the agent's perceptual inputs at
 * any given instant.  An agent's __percept sequence__ is the complete history
 * of everything the agent has ever perceived.  In general, _an agent's choice
 * of action at any given instant can depend on the entire percept sequence
 * observed to date, but not on anything it hasn't perceived_." -- AIMA3e,
 * page 34.
 */
public protocol IPercept {

}

// ////////////////////////////////////////////////////////////////////////////

/**
 * Describes an `Action` that can or has been taken by an `Agent` via
 * one of its actuators.
 */
public protocol IAction {

  /**
   * Adopters of this protocol must implement `getValue()` so that
   * functions defined abstractly using `IAction` as a parameter can
   * display information about the actual `Action` they are referencing.
   *
   * Here is an example for the case in which `IAction` is implemented
   * as a Swift enum:
   * ```swift
   * enum Action: String, IAction {
   *   case noOp, moveRight, moveUp, drinkJava, etc
   *   func getValue() -> String { return self.rawValue }
   * }
   * ```
   */
  func getValue() -> String // Adopters typically { return self.rawValue }
}

// ////////////////////////////////////////////////////////////////////////////

/**
 * "Mathematically speaking, we say that an agent's behavior is described by
 * the __agent function__ that maps any given percept sequence to an action.
 * [The agent function is] an _external_ characterization of the agent.
 * _Internally_, the agent function for an artificial agent will be
 * implemented by an __agent program__.  It is important to keep these two
 * ideas distinct." -- AIMA3e, page 35.
 *
 * - Parameter percept: The current percept of a sequence perceived by the Agent.
 * - Returns: The Action to be taken in response to the currently perceived percept.
*/
public typealias ActorProgram<T> = (_ percept: IPercept) -> T
public typealias AgentProgram = ActorProgram<IAction>
public typealias JudgeProgram = ActorProgram<Double>
public class IActor<T>: EnvironmentObject { // Erase `EnvironmentObject`?
  /**
   * The *agent function* that maps percepts to actions.
   */
  let execute: ActorProgram<T>

  /**
   * Custom initializer sets AgentProgram for this agent.
   *
   * - Parameter program: The agent's program.
   */
  public init(_ program: @escaping ActorProgram<T>) {
    execute = program
  }
}

/**
 * An `Agent` is an `Actor` that returns an `Action`.
 */
public class IAgent: IActor<IAction> {
  /**
   * Life-cycle indicator as to the liveness of an Agent.
   */
  var isAlive = true
}

/**
 * A `Judge` is an `Actor` that returns a `Double` representing the score
 * assigned to an `Agent`'s last `Action`.
 */
public class IJudge: IActor<Double> {

}
//
// Swift: That says AgentProgram is a function type that takes a Percept
// and returns an Action.
//

/**
 * We treat _performance measurement programs_ as `Agent`s but call them
 * `Judge`s to simplify discourse.
 *
 * Like `Agent`s, `Judge`s must be initialized with their program and, if
 * they maintain state, that state must be contained within the judge's
 * program.  `Judge`s cannot look around and see the entire task environment;
 * they can only see the `Percept`s handed to them by their `Environment`.
 *
 * Unlike `Agent` `Percept`s which might resemble `(Location, Dirty)` or
 * `(Location, Clean)`, the only thing a `Judge` sees is _changes_ to the
 * `Environment`:  at each time step, the `Environment` passes a list of
 * changes an `Agent`'s actions may have caused to the `Judge` for scoring.
 * So `Judge`s _know nothing_ about the `Agent`s causing the change.  For
 * example, a pretty `Agent` might skew the `Judge`s scoring; we prevent
 * that...
 */
//public class IJudge: IAgent {
//}
//extension Double: IAction {
//  public func getValue() -> String { return String(self) }
//}
//public class IJudge: Object {
//  /**
//   * The *judge function* that maps percepts to actions.
//   */
//  internal(set) var execute: JudgeProgram
//
//  /**
//   * Custom initializer sets AgentProgram for this agent.
//   *
//   * - Parameter program: The agent's program.
//   */
//  public init(_ program: @escaping JudgeProgram) {
//    execute = program
//  }
//}

// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  ENVIRONMENTS  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

/**
 * Root of the `Environment` hierarchy, this class defines common
 * functionality of any environment but must be subclassed to complete the
 * definition and avoid a runtime crash.
 */
//struct Thing {
//  var agent: IAgent
//  var judges: Dictionary<IJudge, Double>
//}
public class IEnvironment {

  // This is just not working for me.  Getting errors like "inner dict is a let constant"
  // or iterators returning a tuple rather than a dictionary?  It is treating contained
  // dictionary as a let struct?
  var agentScores = Dictionary<IAgent, Dictionary<IJudge, Double>>()
//  public class Score { // A score given by this judge to an agent.
//    let judge: IJudge
//    var value: Double
//    init(judge: IJudge, value: Double) {
//      self.judge = judge
//      self.value = value
//    }
//  }
//  var agentScores = Dictionary<IAgent, [Score]>()

  var envObjects = Dictionary<EnvironmentObject, Location>()
  // let performanceMeasures: [IAgent: Double] = [:]
  
  ///
  /// The Euclidean space used by this environment.
  ///
  let space: Space
  
  ///
  /// The views or observers watching this environment.
  ///
  var views = Set<EnvironmentView>()

  /**
   * Initialize the root environment with a `Space`.
   *
   * - Parameter space: The space to use for this environment.
   */
  public init(_ space: Space) {
    self.space = space
  }

  // Methods to be implemented by subclasses.

  /**
   * Alter environment according to action just taken by incoming agent.
   * For example, if a vacuum agent just did `Suck` then remove all `Dirt`
   * from its current location (assuming `Suck` is 100% successful).
   *
   * This method must be overriden by concrete subclasses.
   *
   * - Parameters:
   *   - agent: The agent that chose this action.
   *   - action: The action chosen by this agent
   */
  public func executeAction(_ agent: IAgent, _ action: IAction) -> [IPercept] {
    fatalError("IEnvironment subclass must define executeAction(agent:action:)!")
  }

  /**
   * Create the `Percept` seen by this `Agent` at its current `Location`.
   *
   * This method must be overriden by concrete subclasses.
   *
   * - Parameter agent: The agent requesting another `Percept`.
   */
  public func getPerceptSeenBy(_ agent: IAgent) -> IPercept {
    fatalError("IEnvironment subclass must define getPerceptSeenBy(agent:)!")
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
//  public func getAgents() -> Set<IAgent> {
//    let copy = agents
//    return copy
//  }

  /**
   * Return all environment objects, along with their location, either from a
   * specified location or, if no location is provided, from the entire environment.
   *
   * - Parameter location: Optional location to retrieve objects from.
   * - Returns: A `Dictionary<EnvironmentObject, Location>` satisfying
   * input criteria.
   */
  public func getObjects(at location: Location?) -> Dictionary<EnvironmentObject, Location> {
    var workArea = [EnvironmentObject: Location]() // Start with empty dictionary.
    if location == nil {
      workArea = envObjects     // Add all entries.
    } else {
      for (key, value) in envObjects {
        if value == location {
          workArea[key] = value // Add only those with matching location.
        }
      }
    }
    // I think this only makes `result` (the reference) and `Location`s immutable...
    let result = workArea
    return result
  }

  /**
   * Add an object to the environment optionally specifying its location.
   * If no location is provided, a random location will be chosen.
   *
   * - Parameters:
   *   - thing:  The object to add to environment.
   *   - location:  Optional location at which to place it.
   */
  public func addObject(_ thing: EnvironmentObject, at location: Location? = nil)
  {
    if envObjects.keys.contains(thing) {
      return // There is only one of each Object, the thing is already here.
    }
    let position = location ?? space.randomLocation()
    if let agent = thing as? IAgent
    {
      envObjects[agent] = position     // Place agent on gameboard.
      agentScores[agent] = [:]         // Agent has no judges or scores yet.
      notifyEnvironmentViews(agent);
    }
    else if let judge = thing as? IJudge
    {
      /*
       * Swift collection iterators like "for (key, value) in myDictionary" are
       * tricky.  Swift unwraps them for you but then makes them "let constants"
       * so you cannot modify values this way.  Probably safer overall...
       *
       * Add new Judge to each Agent's scoring dictionary.
       */
      for agent in agentScores.keys {
        agentScores[agent]![judge] = 0.0
      }
    }
    else
    {
      envObjects[thing] = position     // Place everything else on gameboard.
    }
  }

  public func removeObject(_ thing: EnvironmentObject) {
    envObjects[thing] = nil // Same effect as removeValue(forKey:).
    if let agent = thing as? IAgent {
      agentScores[agent] = nil // Removes both key and value.
    }
    if let judge = thing as? IJudge {
      for agent in agentScores.keys {
        agentScores[agent]![judge] = nil
      }
    }
  }

//  /**
//   * Central template method for controlling agent simulation. The concrete
//   * behavior is determined by the primitive operations
//   * {@link #getPerceptSeenBy(Agent)}, {@link #executeAction(Agent, Action)},
//   * and {@link #createExogenousChange()}.
//   */
  public func step() {
    for agent in agentScores.keys {
      if agent.isAlive {
        //
        // Synthesize an AgentPercept and ask Agent to map it to an AgentAction.
        //
        let agentPercept = getPerceptSeenBy(agent)
        let agentAction = agent.execute(agentPercept)
        //
        // Map AgentAction onto actual Environment changes and save
        // as list of JudgePercepts for any interested Judges.
        //
        let environmentChanges = executeAction(agent, agentAction)
        //
        // Let each Judge update score for this Agent.
        //
        var scores = agentScores[agent]!  // That is Dictionary<IJudge, Double>.
        for judgePercept in environmentChanges {
          for judge in scores.keys {
            scores[judge]! += judge.execute(judgePercept)
          }
        }
        notifyEnvironmentViews(agent, agentPercept, agentAction);
      }
    }
//    createExogenousChange();
  }

  public func step(_ count: Int) {
    for _ in 1...count {
      step();
    }
  }

  public func stepUntilDone() {
    while !isDone() {
      step();
    }
  }

  public func isDone() -> Bool {
    for agent in agentScores.keys {
      if agent.isAlive {
        return false
      }
    }
    return true;
  }

  public func getScores(forAgent: IAgent) -> [IJudge: Double]? {
    return agentScores[forAgent]
  }

  public func addEnvironmentView(_ view: EnvironmentView) {
    views.insert(view)
  }

  public func removeEnvironmentView(_ view: EnvironmentView) {
    views.remove(view);
  }

  public func notifyViews(_ message: String) {
    for view in views {
      view.notify(message);
    }
  }

  // END-Environment
  //

  //
  // PROTECTED METHODS
  //

  func notifyEnvironmentViews(_ agent: IAgent) {
    for view in views {
      view.agentAdded(agent, self);
    }
  }

  func notifyEnvironmentViews(_ agent: IAgent, _ percept: IPercept, _ action: IAction) {
    for view in views {
      view.agentActed(agent, percept, action, self);
    }
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
 * Superclass for a hierarchy of observers and trackers to view the
 * interaction of Agent(s) with an Environment.  Subclasses may override
 * default NOOP implementations with desired behavior.
 */
public class EnvironmentView: EnvironmentObject {
  /**
   * A simple notification message from an object in the Environment.
   *
   * - Parameter message: The message received.
   */
  public func notify(_ message: String) {

  }

  /**
   * Indicates an Agent has been added to the environment and what it
   * perceives initially.
   *
   * - Parameter agent: The Agent just added to the Environment.
   * - Parameter source: The Environment to which the agent was added.
   */
  public func agentAdded(_ agent: IAgent, _ source: IEnvironment) {
  
  }

  /**
   * Indicates the Environment has changed as a result of an Agent's action.
   *
   * - Parameters:
   *   - agent:   The Agent that performed the Action.
   *   - percept: The Percept the Agent received from the environment.
   *   - action:  The Action the Agent performed.
   *   - source:  The Environment in which the agent has acted.
   */
  public func agentActed(_ agent:   IAgent,
                         _ percept: IPercept,
                         _ action:  IAction,
                         _ source:  IEnvironment
                        )
  {
  
  }
}


// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  EUCLIDEAN SPACE  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

/**
 * For problems involving N-dimensional Cartesian locations, it is simpler to
 * implement one concrete model than multiple custom spaces like `(left, right)`
 * and is arguably clearer.
 *
 * This class models an N-dimensional `Space` of integer coordinates where
 * `N >= 0`.  Each dimension is initialized with a half-open interval, or
 * `Range`, like `0..<10` or `-5..<5`.  A `Location` then is just an array
 * of integers.
 *
 * The default initializer generates the special case of `N = 0` and permits
 * expressions like
 * ```swift
 * let mySpace = Space()
 * ```
 * which gives you a concrete representation of nothing (in case you
 * are working on big bang theory).
 */
public class Space {
  let ranges: [Range<Int>]

  /**
   * Method initializes `Space` instance with zero or more `Range`s.
   *
   * - Parameters:
   *     - ranges: The list of ranges, one per dimension.
   */
  public init(_ ranges: Range<Int>...) {
    self.ranges = ranges
  }
  
  /**
   * - Returns: The number of dimensions of this space (i.e., the number of
   *            ranges supplied at initialization).
   */
  public func getDimension() -> Int { return ranges.count }
  
  /**
   * Method checks whether a given `Location` is _inside_ this `Space`.
   *
   * A `location` is _inside_ iff it's dimension is no greater than the `Space`'s
   * and each of its coordinates is contained in the corresponding `Space` range.
   *
   * - Parameter location: The `Location` to test for containment.
   * - Returns: True if `location` is inside this `Space`; otherwise, false.
   */
  public func contains(_ location: Location) -> Bool {
    //
    // Does nothing contain nothing?
    //
    if ranges.isEmpty || location.isEmpty {
      return false
    }
    //
    // The relation is `contains`, not `intersects`.
    //
    if ranges.count < location.count {
      return false
    }
    //
    // Check each coordinate for containment.
    //
    for i in 0 ..< min(ranges.count, location.count) {
      if !ranges[i].contains(location[i]) {
        return false
      }
    }
    return true
  }

  /**
   * Returns: A random location inside the space.
   */
  public func randomLocation() -> Location {
    var location = [Int]()
    for range in ranges {
      location.append(Int.random(in: range))
    }
    return location
  }
}

// ////////////////////////////////////////////////////////////////////////////

/**
 * A `Location` is just an array of coordinates in its underlying `Space`.
 */
public typealias Location = [Int]


// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  LANGUAGE  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

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
