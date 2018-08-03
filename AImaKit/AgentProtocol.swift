//
//  AgentProtocol.swift
//  AImaKit
//
//  Created by Dave King on 8/2/18.
//

import Foundation

//public protocol ActionProtocol { }
//public protocol PerceptProtocol { }

public protocol AgentProtocol {
    associatedtype ActionType
    associatedtype PerceptType
    func execute(_ percept: PerceptType) -> ActionType
}

public protocol JudgeProtocol {
    associatedtype PerceptType
    func execute(_ percept: PerceptType) -> Double
}

public struct SomeAgent: Hashable, AgentProtocol {
    public func execute(_ percept: String) -> Int {
        return 2
    }
}

//struct DX<A: Hashable> where A: AgentProtocol {
//    var dict = Dictionary<A, Int>()
//    func foo() {
//        if let key = dict.keys.first {
//            key.execute("Hello")
//        }
//    }
//}
//
//class AG<A: Hashable, AgentProtocol> {
//    var dict = Dictionary<A, Int>()
//    init(a: A) {
//        dict = [A: Int]
//    }
//}
