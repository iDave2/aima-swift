//
//  SimpleActionTracker.swift
//  AImaKit
//
//  Created by Dhave King on 6/29/18.
//

import Foundation

/**
 * Environment view implementation which logs performed action and
 * provides a comma-separated String with all actions performed so far.
 *
 * Courtesy of Ruediger Lunde.
 */
public class SimpleActionTracker: EnvironmentView {

  var actions: [String] = []

  public func getActions() -> String {
    return actions.joined(separator: ", ")
  }

  public override func agentActed
    (_: Agent, _: Percept, _ action: Action, _: Environment) -> Void
  {
    actions.append(action.rawValue)
  }
}
