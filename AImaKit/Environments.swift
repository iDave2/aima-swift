//
//  Environments.swift
//  AImaKit
//

import Foundation

// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  ENVIRONMENTS  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

/**
 * Root of the `Environment` hierarchy, this class defines common
 * functionality of any environment but must be subclassed to complete the
 * definition and avoid a runtime crash.
 */
public class AnEnvironment {
    
    // STATE
    
    /**
     * The Euclidean space used by this environment.
     *
     * For the two-square vacuum world, one may use
     * ```swift
     * space = Space(0..<2)
     * ```
     * which has two Cartesian coordinates or `Locations`, `[0]` and `[1]`.
     */
    let space: Space
    
    /**
     * Except for `Judges`, every object added to the `Environment` goes into
     * this dictionary along with its `Location`.
     */
    var envObjects = Dictionary<EnvironmentObject, Location>()
    
    /**
     * At each time step, each agent in the environment attempts to perform
     * an action and each judge scores the effort by observing actual changes
     * to the environment.  This dictionary of dictionaries keeps track of
     * these associations and scores.
     */
    var agentScores = Dictionary<AnAgent, Dictionary<AJudge, Double>>()
    
    /**
     * The views or observers watching or _listening to_ this environment.
     */
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


    // ABSTRACT CRASHERS (in lieu of abstract classes)
    
    /**
     * Alter environment according to action just taken by incoming agent.
     * For example, if a vacuum agent just did `Suck` then remove all `Dirt`
     * from its current location (assuming `Suck` is 100% successful).
     *
     * - Attention: This method must be overriden by concrete subclasses.
     *
     * - Parameters:
     *   - agent: The agent responsible for this action.
     *   - action: The action chosen by this agent
     *
     * - Returns: List of _changes to the environment_, if any, caused by
     * agent's action.  These are the `Percepts` seen by judges.
     */
    public func executeAction(_ agent: AnAgent, _ action: IAction) -> [IPercept] {
        fatalError("AnyEnvironment subclass must define executeAction(agent:action:).")
    }
    
    /**
     * Create the `Percept` seen by this `Agent` at its current `Location`.
     *
     * - Attention: This method must be overriden by concrete subclasses.
     * - Parameter agent: The agent requesting another `Percept`.
     * - Returns: An agent percept.
     */
    public func getPerceptSeenBy(_ agent: AnAgent) -> IPercept {
        fatalError("AnyEnvironment subclass must define getPerceptSeenBy(agent:).")
    }
    
    // CONFIGURATION
    
    /**
     * Add an object to the environment optionally specifying its location.
     * If no location is provided, a random one will be chosen.
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
    
    // Not used (yet).
    //
    // public func removeObject(_ thing: EnvironmentObject) {
    //     envObjects[thing] = nil // Same effect as removeValue(forKey:).
    //     if let agent = thing as? AnAgent {
    //         agentScores[agent] = nil // Removes both key and value.
    //     }
    //     if let judge = thing as? AJudge {
    //         for agent in agentScores.keys {
    //             agentScores[agent]![judge] = nil
    //         }
    //     }
    // }
    
    // CLOCK (where simulation begins)
    
    public func step() {
        for agent in agentScores.keys {
            if !agent.isAlive {
                continue
            }
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
        // createExogenousChange();
    }
    
    public func step(_ count: Int) {
        for _ in 1...count {
            step();
        }
    }
    
    // Not used.
    //
    // public func stepUntilDone() {
    //     while !isDone() {
    //         step();
    //     }
    // }
    
    // Not used.
    //
    // public func isDone() -> Bool {
    //     for agent in agentScores.keys {
    //         if agent.isAlive {
    //             return false
    //         }
    //     }
    //     return true;
    // }
    
    // PERFORMANCE
    
    public func getScores(forAgent: AnAgent) -> [AJudge: Double]? {
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
    
    func notifyEnvironmentViews(_ agent: AnAgent) {
        for view in views {
            view.agentAdded(agent, self);
        }
    }
    
    func notifyEnvironmentViews(_ agent: AnAgent, _ percept: IPercept, _ action: IAction) {
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
    public func agentAdded(_ agent: AnAgent, _ source: AnEnvironment) {
    
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
    public func agentActed(_ agent:   AnAgent,
                           _ percept: IPercept,
                           _ action:  IAction,
                           _ source:  AnEnvironment)
    {
        
    }
}
