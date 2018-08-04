//
//  Agent.swift
//  AImaKit
//
//  Created by Dave King on 8/2/18.
//

import Foundation

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
 */
public protocol Agent {
    associatedtype ActionType
    associatedtype PerceptType
    func execute(_ percept: PerceptType) -> ActionType
}

/**
 * Performance measures are represented by judges.
 *
 * So a performance measure, or the program that implements it, takes a
 * sequence of environment states (like a percept sequence), and returns
 * a _score_ (like an action).  Modeling this as an agent may help to
 * decouple things:
 *
 * - A `Judge` has no idea how its `Agents` work;  it just sees changes to
 *   the `Environment`.
 * - An `Environment` does not know what formula its `Judges` use to score
 *   changes; it just gives them a `Percept` and gets back a score.
 *
 * `Actions` returned by different agent types may differ.  An AIMA3e
 * `Agent` may return `Suck` while its `Judge` returns `+10`.
 *
 * `Environments` synthesize `Percepts` for `Agents` and `Judges` and these
 * may also differ.  For example, while an `Agent` may see a sequence of
 * `Percepts` in the local vicinity like `(Location, Dirty)`, its `Judge` sees
 * a sequence of `Environment` changes like `(dirtRemoved, atLocation)`.  If
 * an `Agent` tries to `MoveLeft` through a wall, its `Judge` might see `NoOp`
 * since nothing changed in the environment.
 *
 */
public protocol JudgeProtocol {
    associatedtype PerceptType
    func execute(_ percept: PerceptType) -> Double
}

