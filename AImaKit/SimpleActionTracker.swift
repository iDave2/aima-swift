//
//  SimpleActionTracker.swift
//  AImaKit
//

import Foundation

/**
 * Environment view implementation which logs performed action and
 * provides a comma-separated String with all actions performed so far.
 */
public class SimpleActionTracker: ObserverDelegate<VacuumWorld.Environment> {

    typealias E = VacuumWorld.Environment // So awkward...

    var actions: [String] = []

    public func getActions() -> String {
        return actions.joined(separator: ", ")
    }

    override func agentActed(_ agent:   E.AgentType,
                             _ percept: E.AgentType.PerceptType,
                             _ action:  E.AgentType.ActionType,
                             _ source:  E)
    {
        actions.append(action.rawValue)
    }

}
