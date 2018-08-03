//
//  SimpleActionTracker.swift
//  AImaKit
//
//  Created by Dave King on 6/29/18.
//

import Foundation

/**
 * Environment view implementation which logs performed action and
 * provides a comma-separated String with all actions performed so far.
 */
public class SimpleActionTracker: ObserverDelegate {

    // public typealias VWE = VacuumWorld.Environment

    var actions: [String] = []
    let env: EuclideanEnvironment

    public func getActions() -> String {
        return actions.joined(separator: ", ")
    }

    public init<E: EuclideanEnvironment>(_ environment: E) {

    }

    public func agentActed(
        _ agent: VWE.AgentType,
        _ percept: VWE.AgentType.PerceptType,
        _ action:  VWE.AgentType.ActionType,
        _ source: VWE)
//    public func agentActed<E: VacuumWorld.Environment>(
//        _ agent: E.AgentType,
//        _ percept: E.AgentType.PerceptType,
//        _ action:  E.AgentType.ActionType,
//        _ source: E)
    {
        actions.append(action.rawValue)
    }
}
