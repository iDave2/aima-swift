//
//  EuclideanEnvironment.swift
//  AImaKit
//
//  Created by Dave King on 8/1/18.
//

import Foundation

/**
 * A protocol for Euclidean environments used in Chapter 2 of AIMA3e, this
 * represents the world as a grid of Cartesian coordinates, a `Space`, that
 * agents move around in.
 *
 * Remember: These protocols are not polymorphic like classes;
 * [review this](https://stackoverflow.com/questions/44703205)
 * and test, test, test.
 */
public protocol EuclideanEnvironment {

    typealias Location = EuclideanSpace.Location

    // ##+####-####+####-####+####-####+####-####+####-####+####-####+####-###
    // MARK: State

    /**
     * The Euclidean space used by this environment.
     *
     * For the two-square vacuum world, one may use
     *
     *     space = Space(0..<2)
     *
     * which has two Cartesian coordinates or `Locations`, `[0]` and `[1]`.
     */
    var space: EuclideanSpace { get set }

    /**
     * Except for `Judges`, every object added to the `Environment` goes into
     * this dictionary along with its `Location`.
     */
    var envObjects: Dictionary<Object, Location> { get set }

    /**
     * Generic agent type for this environment.
     */
    associatedtype AgentType: Object, Agent
    /**
     * Generic judge type for his environment.
     */
    associatedtype JudgeType: Object, Judge
    /**
     * Cumulative scores from each judge (performance measure) for each agent.
     *
     * At each time step, each agent in the environment attempts to perform
     * an action and each judge scores the effort by observing actual changes
     * to the environment.  This dictionary of dictionaries keeps track of
     * these associations and scores.
     */
    var scores: Dictionary<AgentType, Dictionary<JudgeType, Double>> { get set }

    /**
     * Delegate to handle any observers _listening to_ this environment.
     */
    var delegate: ObserverDelegate<Self>? { get set }


    // ##+####-####+####-####+####-####+####-####+####-####+####-####+####-###
    // MARK: Contents

    /**
     * Add an object to the environment optionally specifying its location.
     * If no location is provided, a random one will be chosen.
     *
     * - Parameters:
     *   - thing:  The object to add to environment.
     *   - location:  Optional location at which to place it.
     */
    mutating func addObject(_ thing: Object, at location: Location?)

    /**
     * Return all environment objects, along with their location, either from a
     * specified location or, if no location is provided, from the entire environment.
     *
     * - Parameter location: Optional location to retrieve objects from.
     * - Returns: A `Dictionary<EnvironmentObject, Location>` satisfying
     * input criteria.
     */
    func getObjects(at location: Location?) -> Dictionary<Object, Location>


    // ##+####-####+####-####+####-####+####-####+####-####+####-####+####-###
    // MARK: Simulation

    /**
     * Move clock forward one click.
     *
     * With each step, agents are presented with the next `Percept` and their
     * resulting `Action` is scored by whatever `Judges` (performance measures)
     * are installed in the environment.
     */
    mutating func step() // Compiler does not require `mutating` here?

    /**
     * Move clock forward by `count` clicks.
     *
     * - Parameter count: Number of clicks to move clock forward by.
     */
    mutating func step(_ count: Int)

    /**
     * Alter environment according to action just taken by incoming agent.
     * For example, if a vacuum agent just did `Suck` then remove all `Dirt`
     * from its current location (assuming `Suck` is 100% successful).
     *
     * - Attention: This method must be overriden by protocol adopters.
     *
     * - Parameters:
     *   - agent: The agent responsible for this action.
     *   - action: The action chosen by this agent
     *
     * - Returns: List of _changes to the environment_, if any, caused by
     * agent's action.  These are the `Percepts` seen by judges.
     */
    func executeAction(_ agent: AgentType, _ action: AgentType.ActionType)
        -> [JudgeType.PerceptType]

    /**
     * Create the `Percept` seen by this `Agent` at its current `Location`.
     *
     * - Attention: This method must be overriden by protocol adopters.
     * - Parameter agent: The agent requesting another `Percept`.
     * - Returns: An agent percept.
     */
    func getPerceptSeenBy(_ agent: AgentType) -> AgentType.PerceptType


    // ##+####-####+####-####+####-####+####-####+####-####+####-####+####-###
    // MARK: Performance

    func getScores(forAgent: AgentType) -> [JudgeType: Double]?

}

// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-***
//  MARK: CONTENTS

extension EuclideanEnvironment {

    public mutating func addObject(_ thing: Object, at location: Location? = nil)
    {
        if envObjects.keys.contains(thing) {
            return // There is only one of each Object, the thing is already here.
        }
        let position = location ?? space.randomLocation()
        if let judge = thing as? JudgeType
        {
            /*
             * Swift collection iterators like "for (key, value) in myDictionary" are
             * tricky.  Swift unwraps them for you but then makes them "let constants"
             * so you cannot modify values this way.  Probably safer, certainly simpler...
             *
             * Add new Judge to each Agent's scoring dictionary unless it is already
             * added.  Judges do not go on "gameboard;" they sit outside the octagon.
             */
            for agent in scores.keys {
                if scores[agent]![judge] == nil {
                    scores[agent]![judge] = 0.0
                }
            }
        }
        else
        {
            envObjects[thing] = position     // Place everything else on gameboard.
            if let agent = thing as? AgentType
            {
                scores[agent] = [:]     // Agent has no judges or scores yet.
                //notifyEnvironmentViews(agent);
            }
        }
    }

    public func getObjects(at location: Location?) -> Dictionary<Object, Location> {
        var workArea = [Object: Location]() // Start with empty dictionary.
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

}

// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-***
// MARK: SIMULATION

extension EuclideanEnvironment {

    public mutating func step() {
        for agent in scores.keys {
            //if !agent.isAlive { // Unknown detail inside protocol definition...
            //    continue
            //}
            //
            // Synthesize an AgentPercept and ask Agent to map it to
            // an AgentAction.
            //
            let agentPercept = getPerceptSeenBy(agent)
            let agentAction = agent.execute(agentPercept)
            //
            // Map AgentAction onto actual Environment changes and save
            // as list of JudgePercepts for any interested Judges.
            //
            let environmentChanges = executeAction(agent, agentAction)
            //
            // Request a score from each Judge and update environment with
            // results.  This is effectively an executeAction() for judges
            // except that we've decoupled the scoring algorithm from the
            // environment.  FWIW.
            //
            for judgePercept in environmentChanges {
                for judge in scores[agent]!.keys {
                    scores[agent]![judge]! += judge.execute(judgePercept)
                }
            }
            // Delegation is still awkward in this generic environment
            // but the pattern is pleasant so here it is.  If delegate
            // has not been set by a controller (i.e., is nil), then
            // this line quietly does nothing; otherwise, it tells delegate
            // what happened.
            delegate?.agentActed(agent, agentPercept, agentAction, self)
        }
        // createExogenousChange();
    }

    public mutating func step(_ count: Int) {
        for _ in 1...count {
            step();
        }
    }

}

// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-***
// MARK: PERFORMANCE

extension EuclideanEnvironment {

    public func getScores(forAgent: AgentType) -> [JudgeType: Double]? {
        return scores[forAgent]
    }

}
