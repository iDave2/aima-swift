//
//  Agents.swift
//  AImaKit
//
//  Created by Dave King on 6/23/18.
//
//  Should this earlier comment,
//
//   "The notation `ISomeType` used in this file means that that type is meant
//    to be subclassed by actual `SomeType`s that satisfy requirements of a
//    particular task environment."
//
//  be replaced with this?
//
//   "This top-level file contains global symbols prefixed with `AIma` so that
//    `AImaKit` symbols do not conflict with other frameworks like `UIKit`."
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
 * So a performance measure, or the program that implements it, takes a
 * sequence of environment states (like a percept sequence), and returns a
 * _score_ (like an action).  In the effort to reuse solutions, consider
 * the following type hierarchy:
 * ```
 *   Actor - An abstract superclass of all agent flavors.
 *     Agent - The AIMA3e agent (as used in the book).
 *     Judge - The AIMA3e performance measure.
 * ```
 * `Action`s returned by different `Actor` subtypes may differ.  An `Agent`
 * may return `Suck` while its `Judge` returns `+10`.
 *
 * `Environment`s synthesize `Percept`s for `Agent`s and `Judge`s and these
 * may also differ.  For example, while an `Agent` may see a sequence of
 * `Percept`s in the local vicinity like `(Location, Dirty)`, its `Judge` sees
 * a sequence of `Environment` changes like `(dirtRemoved, atLocation)`.  If
 * an `Agent` tries to `MoveLeft` through a wall, its `Judge` might see `NoOp`
 * since nothing changed in the environment.
 *
 * This decouples `Agent`s, `Judge`s, and their `Environment`s somewhat:
 *
 * - A `Judge` has no idea how its `Agent`s work;  it just sees changes to
 *   the `Environment`.
 * - An `Environment` does not know what formula its `Judge`s use to score
 *   changes; it just gives them a `Percept` and gets back a score.
 */
public class IActor<T>: EnvironmentObject {
  /**
   * The *agent function* that maps percepts to actions.
   */
  internal(set) public var execute: ActorProgram<T> = { _ in
    fatalError("Agent program is not initialized!")
  }
  
  /**
   * Internal default initializer lets agent programs referencing subclass
   * state to compile without strong reference cycle errors.
   *
   * Default agent program crashes.
   */
  override init() {
    // Default value above, subclass must fix when this returns.
    print("IActor<T> (default) initialized.")
  }

  /**
   * Custom initializer defines program used by this agent.
   *
   * - Parameter program: The agent's program.
   */
  public init(_ program: @escaping ActorProgram<T>) {
    execute = program
    print("IActor<T> (custom) initialized.")
  }
  
  // Used for debugging memory leaks.
  deinit { print("IActor<T> deinitialized.") }
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
 * `ActorProgram<T>` is a generic function that takes a `Percept` and returns
 * a `T` which, in this case, represents an `Action`.
 *
 * - Parameter percept: The current `Percept` of a sequence perceived by the
 *   `Actor`.
 * - Returns: The `Action` to be taken in response to the current `Percept`.
*/
public typealias ActorProgram<T> = (_ percept: IPercept) -> T

// ////////////////////////////////////////////////////////////////////////////

/**
 * The AIMA3e __agent__.
 */
public class IAgent: IActor<IAction> {
  /**
   * Life-cycle indicator as to the liveness of an Agent.
   */
  var isAlive = true
}

/**
 * The AIMA3e __performance measure__.
 */
public class IJudge: IActor<Double> {

}

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
  func getValue() -> String
}

// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  ENVIRONMENTS  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

/**
 * Root of the `Environment` hierarchy, this class defines common
 * functionality of any environment but must be subclassed to complete the
 * definition and avoid a runtime crash.
 */
public class IEnvironment {

  // STATE

  /**
   * Except for `Judge`s, every object added to the `Environment` goes into
   * this dictionary along with its `Location`.
   */
  var envObjects = Dictionary<EnvironmentObject, Location>()
  
  /**
   * At each time step, each agent in the environment attempts to perform
   * an action and each judge scores that effort by observing actual changes
   * to the environment.
   *
   * This dictionary of dictionaries keeps track of those associations and
   * scores.
   */
  var agentScores = Dictionary<IAgent, Dictionary<IJudge, Double>>()

  ///
  /// The Euclidean space used by this environment.
  ///
  let space: Space
  
  ///
  /// The views or observers watching this environment.
  ///
  var views = Set<EnvironmentView>()

  // INITIALIZATION

  /**
   * Initialize the root environment with a `Space`.
   *
   * - Parameter space: The space to use for this environment.
   */
  public init(_ space: Space) {
    self.space = space
  }

  // ABSTRACT CRASHERS (override in subtypes)

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
  
  // CONFIGURATION

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

  // CLOCK (where simulation begins)

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
        // Request a score from each Judge and update environment with results.
        // This is effectively an executeAction() for judges except that we've
        // decoupled the scoring algorithm from the environment.  FWIW.
        //
        for judgePercept in environmentChanges {
          for judge in agentScores[agent]!.keys {
            agentScores[agent]![judge]! += judge.execute(judgePercept)
          }
        }
        notifyEnvironmentViews(agent, agentPercept, agentAction);
      }
    }
    // createExogenousChange();
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
  
  // PERFORMANCE

  public func getScores(forAgent: IAgent) -> [IJudge: Double]? {
    return agentScores[forAgent]
  }
  
  // OBSERVERS

  public func addEnvironmentView(_ view: EnvironmentView) {
    views.insert(view)
  }

  public func removeEnvironmentView(_ view: EnvironmentView) {
    views.remove(view);
  }

  func notifyViews(_ message: String) {
    for view in views {
      view.notify(message);
    }
  }

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
  
  /**
   * Generate a model of this space initialized with the given value.
   *
   * There are no doubt better ways to do this but, for now, here is
   * an example of usage:
   * ```
   * let space = Space(0..<3, 0..<2, 0..<1)  // That's 3x2x1 cuboid.
   * guard let array = space.toArray(repeating: "unknown") as? [[[String]]] else {
   *   fatalError("Cannot construct array from space \(space).")
   * }
   * print("let array: [[[String]]] =", array)
   * ```
   *
   * - Parameter repeating: The value to initialize array with.
   * - Returns: An N-dimensional array initialized with incoming element
   *            or nil if Space is Nothing or something else failed.
   */
  public func toArray<Element>(repeating: Array<Element>.Element) -> AnyObject? {
    if ranges.isEmpty {
      return nil
    }
    var backward = ranges
    backward.reverse()           // Why must this be "in place?" Odd.
    var any = repeating as Any   // Any's type will keep changing.
    for range in backward {
      any = Array(repeating: any, count: range.count) as AnyObject
    }
    return any as AnyObject
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
 * default implementations as needed.
 */
public class Object: Hashable {

  // Explicitly increase access level from default 'internal' to 'public'.
  public init() { }
  
  // Two object or instance references are equal if and only if they point to
  // the same address, the same memory.
  public static func == (lhs: Object, rhs: Object) -> Bool {
    return lhs === rhs
  }
  
  // These hash values also use address-like discrimination.
  public var hashValue: Int { return ObjectIdentifier(self).hashValue }
}
