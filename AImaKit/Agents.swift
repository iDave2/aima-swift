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
//  VERIFY THIS LINE PUSHES ONTO remotes/origin/adjustment
//

/**
 * # Does Anyone Process This?
 *
 * Would be swell if we could have header overview on Swift doc pages...
 * I don't think so. Remember, Swift namespace is big flat entire module.
 * Probably need more for more.
 *
 * - Authors:
 *   - Dave
 *   - Susy
 */

import Foundation


// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  AGENTS  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

/**
 * 'An **agent** is anything that can be viewed as perceiving its
 * __environment__ through __sensors__ and acting upon that environment
 * through __actuators__.' -- AIMA3e, page 34.
 *
 * See [here](https://github.com/realm/jazzy/issues/992) for jazzy issue with
 * quotes.
 *
 * 'When an agent is plunked down in an environment, it generates a sequence
 * of actions according to the percepts it receives. This sequence of actions
 * causes the environment to go through a sequence of states.  If the sequence
 * is _desirable_, then the agent has _performed well_.  This notion of
 * desirability is captured by a __performance measure__ that evaluates any
 * given sequence of environment states.' -- AIMA3e, page 37, italics mine.
 *
 * So a performance measure, or the program that implements it, takes a
 * sequence of environment states (like a percept sequence), and returns a
 * _score_ (like an action).  In the effort to reuse solutions, consider
 * the following type hierarchy:
 * ```text
 *   Actor - An abstract superclass of all agent flavors.
 *     Agent - The AIMA3e agent (as used in the book).
 *     Judge - The AIMA3e performance measure.
 * ```
 * `Actions` returned by different `Actor` subtypes may differ.  An `Agent`
 * may return `Suck` while its `Judge` returns `+10`.
 *
 * `Environments` synthesize `Percepts` for `Agents` and `Judges` and these
 * may also differ.  For example, while an `Agent` may see a sequence of
 * `Percepts` in the local vicinity like `(Location, Dirty)`, its `Judge` sees
 * a sequence of `Environment` changes like `(dirtRemoved, atLocation)`.  If
 * an `Agent` tries to `MoveLeft` through a wall, its `Judge` might see `NoOp`
 * since nothing changed in the environment.
 *
 * This decouples `Agents`, `Judges`, and their `Environments` somewhat:
 *
 * - A `Judge` has no idea how its `Agents` work;  it just sees changes to
 *   the `Environment`.
 * - An `Environment` does not know what formula its `Judges` use to score
 *   changes; it just gives them a `Percept` and gets back a score.
 */
//public class AnActor<T>: Object {
//  /**
//   * The *agent function* that maps percepts to actions.
//   */
//  public func execute(_ percept: IPercept) -> T {
//    fatalError("Agent program is not initialized!")
//  }

//  /**
//   * Internal default initializer lets agent programs referencing subclass
//   * state to compile without strong reference cycle errors.
//   *
//   * Default agent program crashes.
//   */
//  override init() {
//    // Default value above, subclass must fix when this returns.
//    print("IActor<T> (default) initialized.")
//  }

//  /**
//   * Custom initializer defines program used by this agent.
//   *
//   * - Parameter program: The agent's program.
//   */
//  public init(_ program: @escaping ActorProgram<T>) {
//    execute = program
//    print("IActor<T> (custom) initialized.")
//  }
//
//  // Used for debugging memory leaks.
//  deinit { print("IActor<T> deinitialized.") }
//}

// ////////////////////////////////////////////////////////////////////////////

/**
 * 'Mathematically speaking, we say that an agent's behavior is described by
 * the __agent function__ that maps any given percept sequence to an action.
 * [The agent function is] an _external_ characterization of the agent.
 * _Internally_, the agent function for an artificial agent will be
 * implemented by an __agent program__.  It is important to keep these two
 * ideas distinct.' -- AIMA3e, page 35.
 *
 * `ActorProgram<T>` is a generic function that takes a `Percept` and returns
 * a `T` which, in this case, represents an `Action`.
 *
 * - Parameter percept: The current `Percept` of a sequence perceived by the
 *   `Actor`.
 * - Returns: The `Action` to be taken in response to the current `Percept`.
*/
// This is not used anywhere...
// public typealias ActorProgram<T> = (_ percept: IPercept) -> T

// ////////////////////////////////////////////////////////////////////////////

/**
 * The AIMA3e __agent__.
 */
//public class AnAgent: AnActor<IAction> {
//  /**
//   * Life-cycle indicator as to the liveness of an Agent.
//   */
//  var isAlive = true
//}

/**
 * The AIMA3e __performance measure__.
 */
//public class AJudge: AnActor<Double> {
//
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
//public protocol IPercept {
//
//}

// ////////////////////////////////////////////////////////////////////////////

/**
 * Describes an `Action` that can or has been taken by an `Agent` via
 * one of its actuators.
 */
//public protocol IAction {
//  /**
//   * Adopters of this protocol must implement `getValue()` so that
//   * functions defined abstractly using `IAction` as a parameter can
//   * display information about the actual `Action` they are referencing.
//   *
//   * Here is an example for the case in which `IAction` is implemented
//   * as a Swift enum:
//   * ```swift
//   * enum Action: String, IAction {
//   *   case noOp, moveRight, moveUp, drinkJava, etc
//   *   func getValue() -> String { return self.rawValue }
//   * }
//   * ```
//   */
//  func getValue() -> String
//}


// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  EUCLIDEAN SPACE  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****


// ////////////////////////////////////////////////////////////////////////////



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
