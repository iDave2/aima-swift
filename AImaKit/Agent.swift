//
//  Agent.swift
//  AImaKit
//
//  Created by Dave King on 8/2/18.
//

import Foundation

/**
 * 'An **agent** is anything that can be viewed as perceiving its
 * __environment__ through __sensors__ and acting upon that environment
 * through __actuators__.' -- AIMA3e, page 34.
 *
 * See [here](https://github.com/realm/jazzy/issues/992) for jazzy issue with
 * quotes.
 */
public protocol Agent {
    associatedtype ActionType
    associatedtype PerceptType
    func execute(_ percept: PerceptType) -> ActionType
}

public protocol JudgeProtocol {
    associatedtype PerceptType
    func execute(_ percept: PerceptType) -> Double
}

