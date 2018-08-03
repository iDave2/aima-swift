//
//  ObserverDelegate.swift
//  AImaKit
//
//  Created by Dave King on 8/3/18.
//

import Foundation

/**
 * Environments send events to a single observer delegate.
 *
 * Multiple listeners are handled here, not by their environments.
 *
 */
public protocol ObserverDelegate {

    /**
     * Indicates the Environment has changed as a result of an Agent's action.
     *
     * - Parameters:
     *   - agent:   The Agent that performed the Action.
     *   - percept: The Percept the Agent received from the environment.
     *   - action:  The Action the Agent performed.
     *   - source:  The Environment in which the agent has acted.
     */
    func agentActed<E: EuclideanEnvironment>(_ agent: E.AgentType,
                                             _ percept: E.AgentType.PerceptType,
                                             _ action:  E.AgentType.ActionType,
                                             _ source: E)

}

// Provide NOOP defaults.

extension ObserverDelegate {

    public func agentActed<E: EuclideanEnvironment>(
        _ agent: E.AgentType,
        _ percept: E.AgentType.PerceptType,
        _ action:  E.AgentType.ActionType,
        _ source: E)
    { }
}
