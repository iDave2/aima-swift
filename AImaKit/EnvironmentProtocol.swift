//
//  EnvironmentProtocol.swift
//  AImaKit
//
//  Created by Dhave King on 8/1/18.
//  Copyright © 2018 Dave King. All rights reserved.
//

import Foundation

/**
 * A protocol for Euclidean environments used in Chapter 2 of AIMA3e, this
 * represents the world as a grid of Cartesian coordinates, a `Space`, that
 * agents move around in.
 *
 * Remember: these protocols only attach a protocol witness table (PWT) to
 * classes that adopt them, but not their subclasses (if any), so you get at
 * most one level of "inheritance" and they call that "static polymorphism."
 * Uh-huh...  Also [see this](https://stackoverflow.com/questions/44703205).
 */
public protocol Environment { // Euclidean, at least, not for graphs.

    //  STATE  ///////////////////////////////////////////////////////////////

    /**
     * The Euclidean space used by this environment.
     *
     * For the two-square vacuum world, one may use
     *
     *     space = Space(0..<2)
     *
     * which has two Cartesian coordinates or `Locations`, `[0]` and `[1]`.
     */
    var space: Space { get set }

    /**
     * Except for `Judges`, every object added to the `Environment` goes into
     * this dictionary along with its `Location`.
     */
    var envObjects: Dictionary<EnvironmentObject, Location> { get set }

    /**
     * At each time step, each agent in the environment attempts to perform
     * an action and each judge scores the effort by observing actual changes
     * to the environment.  This dictionary of dictionaries keeps track of
     * these associations and scores.
     */
    var agentScores: Dictionary<AnAgent, Dictionary<AJudge, Double>> { get set }

    /**
     * The views or observers watching or _listening to_ this environment.
     */
    var views: Set<EnvironmentView> { get set }


    //  CONTENTS  ////////////////////////////////////////////////////////////

    /**
     * Add an object to the environment optionally specifying its location.
     * If no location is provided, a random one will be chosen.
     *
     * - Parameters:
     *   - thing:  The object to add to environment.
     *   - location:  Optional location at which to place it.
     */
    mutating func addObject(_ thing: EnvironmentObject, at location: Location?)

    /**
     * Return all environment objects, along with their location, either from a
     * specified location or, if no location is provided, from the entire environment.
     *
     * - Parameter location: Optional location to retrieve objects from.
     * - Returns: A `Dictionary<EnvironmentObject, Location>` satisfying
     * input criteria.
     */
    func getObjects(at location: Location?) -> Dictionary<EnvironmentObject, Location>


    //  TIME  ////////////////////////////////////////////////////////////////

    /**
     * Move clock forward one click.
     */
    func step()

    /**
     * Move clock forward by `count` clicks.
     *
     * - Parameter count: Number of clicks to move clock forward by.
     */
    func step(_ count: Int)


    //  PERFORMANCE  /////////////////////////////////////////////////////////

    func getScores(forAgent: AnAgent) -> [AJudge: Double]?


    //  OBSERVERS  ///////////////////////////////////////////////////////////

    mutating func addEnvironmentView(_ view: EnvironmentView)

    func notifyEnvironmentViews(_ agent: AnAgent)

    func notifyEnvironmentViews(_ agent: AnAgent, _ percept: IPercept, _ action: IAction)

}

//  CONTENTS  ////////////////////////////////////////////////////////////////

extension Environment {

    public mutating func addObject(_ thing: EnvironmentObject, at location: Location? = nil)
    {
        if envObjects.keys.contains(thing) {
            return // There is only one of each Object, the thing is already here.
        }
        let position = location ?? space.randomLocation()
        if let judge = thing as? AJudge
        {
            /*
             * Swift collection iterators like "for (key, value) in myDictionary" are
             * tricky.  Swift unwraps them for you but then makes them "let constants"
             * so you cannot modify values this way.  Probably safer, certainly simpler...
             *
             * Add new Judge to each Agent's scoring dictionary unless it is already
             * added.  Judges do not go on "gameboard;" they sit outside the octagon.
             */
            for agent in agentScores.keys {
                if agentScores[agent]![judge] == nil {
                    agentScores[agent]![judge] = 0.0
                }
            }
        }
        else
        {
            envObjects[thing] = position     // Place everything else on gameboard.
            if let agent = thing as? AnAgent
            {
                envObjects[agent] = position     // Place agent on gameboard.
                agentScores[agent] = [:]         // Agent has no judges or scores yet.
                notifyEnvironmentViews(agent);
            }
        }
    }

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

}

//  TIME  ////////////////////////////////////////////////////////////////////

extension Environment {

    // TODO: Need to resolve crashers before this compiles.
//    public func step() {
//        for agent in agentScores.keys {
//            if !agent.isAlive {
//                continue
//            }
//            //
//            // Synthesize an AgentPercept and ask Agent to map it to an AgentAction.
//            //
//            let agentPercept = getPerceptSeenBy(agent)
//            let agentAction = agent.execute(agentPercept)
//            //
//            // Map AgentAction onto actual Environment changes and save
//            // as list of JudgePercepts for any interested Judges.
//            //
//            let environmentChanges = executeAction(agent, agentAction)
//            //
//            // Request a score from each Judge and update environment with results.
//            // This is effectively an executeAction() for judges except that we've
//            // decoupled the scoring algorithm from the environment.  FWIW.
//            //
//            for judgePercept in environmentChanges {
//                for judge in agentScores[agent]!.keys {
//                    agentScores[agent]![judge]! += judge.execute(judgePercept)
//                }
//            }
//            notifyEnvironmentViews(agent, agentPercept, agentAction);
//        }
//        // createExogenousChange();
//    }

    public func step(_ count: Int) {
        for _ in 1...count {
            step();
        }
    }

}

//  PERFORMANCE  /////////////////////////////////////////////////////////////

extension Environment {

    public func getScores(forAgent: AnAgent) -> [AJudge: Double]? {
        return agentScores[forAgent]
    }

}

//  OBSERVERS  ///////////////////////////////////////////////////////////////

extension Environment {

    public mutating func addEnvironmentView(_ view: EnvironmentView) {
        views.insert(view)
    }

    public func notifyEnvironmentViews(_ agent: AnAgent) {
        for view in views {
            view.agentAdded(agent, self);
        }
    }

    public func notifyEnvironmentViews(_ agent: AnAgent, _ percept: IPercept, _ action: IAction) {
        for view in views {
            view.agentActed(agent, percept, action, self);
        }
    }

}
