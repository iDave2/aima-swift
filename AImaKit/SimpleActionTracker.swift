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
public class SimpleActionTracker { // : ObserverDelegate {

//    public func agentActed<E>(_ agent: E.AgentType,
//                              _ percept: E.AgentType.PerceptType,
//                              _ action: E.AgentType.ActionType,
//                              _ source: E)
//        where E : EuclideanEnvironment
//    {
//        <#code#>
//    }



    var actions: [String] = []
    public func getActions() -> String {
        return actions.joined(separator: ", ")
    }

//    public typealias VW = VacuumWorld
//    public func agentActed(_ agent:   VW.AnyAgent,
//                           _ percept: VW.AgentPercept,
//                           _ action:  VW.AgentAction,
//                           _ source:  VW.Environment)
//    {
//        actions.append(action.rawValue)
//    }

//    public func agentActed(
//        _ agent: VWE.AgentType,
//        _ percept: VWE.AgentType.PerceptType,
//        _ action:  VWE.AgentType.ActionType,
//        _ source: VWE)
//    public func agentActed<E: VacuumWorld.Environment>(
//        _ agent: E.AgentType,
//        _ percept: E.AgentType.PerceptType,
//        _ action:  E.AgentType.ActionType,
//        _ source: E)
//    public func agentActed<E>(_ agent: E.AgentType,
//                              _ percept: E.AgentType.PerceptType,
//                              _ action: E.AgentType.ActionType,
//                              _ source: E) where E : VacuumWorld.Environment //EuclideanEnvironment
//    {
//        actions.append(action.rawValue)
//    }
//    {
//        actions.append(action.rawValue)
//    }
}
