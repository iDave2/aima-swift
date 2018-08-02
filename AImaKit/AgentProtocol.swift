//
//  AgentProtocol.swift
//  AImaKit
//
//  Created by Dave King on 8/2/18.
//

import Foundation

public protocol ActionProtocol { }

public protocol PerceptProtocol { }

public protocol AgentProtocol {
    func execute(_ percept: PerceptProtocol) -> ActionProtocol
}
