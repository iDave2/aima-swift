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
public class SimpleActionTracker: View<VacuumWorld.Environment> {

    public typealias VW = VacuumWorld

    var actions: [String] = []

    public func getActions() -> String {
        return actions.joined(separator: ", ")
    }

    public override func agentActed(
        _ agent: VW.AnyAgent,
        _ percept: VW.AgentPercept,
        _ action:  VW.AgentAction,
        _ source: VW.Environment)
    {
        actions.append(action.rawValue)
    }
}
