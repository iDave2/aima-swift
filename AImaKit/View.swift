//
//  Environments.swift
//  AImaKit
//

import Foundation

/**
 * Superclass for a hierarchy of observers and trackers to view the
 * interaction of Agent(s) with an Environment.  Subclasses may override
 * default NOOP implementations with desired behavior.
 *
 * This stuff might better reside in an Observers protocol or facsimile...
 *
 * Also, this class recently became constrained to EuclideanEnvironment?
 */
public class View<E: EuclideanEnvironment>: Object {

    /**
     * A simple notification message from an object in the Environment.
     *
     * - Parameter message: The message received.
     */
    public func notify(_ message: String) { }
    
    /**
     * Indicates an Agent has been added to the environment and what it
     * perceives initially.
     *
     * - Parameter agent: The Agent just added to the Environment.
     * - Parameter source: The Environment to which the agent was added.
     */
    public func agentAdded(_ agent: E.AgentType, _ source: E) { }

    // **+****-****+****-****+****-****+****-****+****-****+****-****+****-***
    
    /**
     * Indicates the Environment has changed as a result of an Agent's action.
     *
     * - Parameters:
     *   - agent:   The Agent that performed the Action.
     *   - percept: The Percept the Agent received from the environment.
     *   - action:  The Action the Agent performed.
     *   - source:  The Environment in which the agent has acted.
     */
    public func agentActed(_ agent:   E.AgentType,
                           _ percept: E.AgentType.PerceptType,
                           _ action:  E.AgentType.ActionType,
                           _ source:  E) { }
}
