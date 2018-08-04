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
 * Modify this delegate to support multiple listeners if needed.
 *
 */
public class ObserverDelegate<E: EuclideanEnvironment> {

    func agentActed(_ agent:   E.AgentType,
                    _ percept: E.AgentType.PerceptType,
                    _ action:  E.AgentType.ActionType,
                    _ source:  E)
    { }
}
