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
public class SimpleActionTracker: EnvironmentView {

  var actions: [String] = []

  public func getActions() -> String {
    return actions.joined(separator: ", ")
  }

  public override func agentActed(_: AnAgent, _: IPercept, _ action: IAction, _: AnEnvironment) {
    actions.append(action.getValue())
  }
}
