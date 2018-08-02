//
//  Environments.swift
//  AImaKit
//

import Foundation

// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  ENVIRONMENTS  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****


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
    public func agentAdded(_ agent: AnAgent, _ source: EuclideanEnvironment) {
    
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
                           _ source:  EuclideanEnvironment)
    {
        
    }
}
