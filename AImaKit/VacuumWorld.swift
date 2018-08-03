//
//  VacuumWorld.swift
//  AImaKit
//
//  Created by Dave King on 6/28/18.
//

import Foundation

// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****
// ---  VACUUM WORLD  ---
// *-****+****-****+****-****+****-****+****-****+****-****+****-****+****-****

/**
 * Artificial Intelligence A Modern Approach (3rd Edition): pg 58.
 *
 * Let the world contain just two locations. Each location may or may not
 * contain dirt, and the agent may be in one location or the other. There are 8
 * possible world states, as shown in Figure 3.2. The agent has three possible
 * actions in this version of the vacuum world: `Left`, `Right`, and `Suck`.
 * Assume for the moment, that sucking is 100% effective. The goal is to
 * clean up all the dirt.
 */
public class VacuumWorld { // Begin VacuumWorld task environment.

    /**
     * Pretty expression for `x = 0` in left-right vacuum world.
     */
    public static let left = [0]
    /**
     * Pretty expression for `x = 1` in left-right vacuum world.
     */
    public static let right = [1]
    /**
     * Pretty expressions for clean-dirty in vacuum world.
     */
    public enum LocationState { case clean, dirty, unknown }
    
    // Simplify / clarify a common type. Got stuff?
    public typealias Stuff = Set<Object>
    
    /**
     * `Dirt` is an `EnvironmentObject` in the `VacuumWorld`.
     */
    public class Dirt: Object { } // Dirt is uncountable?  Dirt() == Dirt()?

    /**
     * Actions an agent can take in this world.
     */
    public enum AgentAction: String {
        case noOp, suck, moveLeft, moveRight, moveUp, moveDown, overheat, blueScreen, etc
        // public func getValue() -> String { return self.rawValue }
    }
    
    /**
     * Percepts an agent sees in this world.
     */
    public struct AgentPercept {
        private(set) public var location: Location
        private(set) public var objects: Stuff

        // Override default internal access level for memberwise initializer.
        public init(location: Location, objects: Stuff) {
            self.location = location
            self.objects = objects
        }
    }

    /**
     * Base class for any agent in this world.
     */
    public class AnyAgent: Object, AgentProtocol {
        // This defines associated types for all agents in this world.
        public func execute(_ percept: AgentPercept) -> AgentAction {
            return .noOp
        }
    }

    /**
     * Actions that a `VacuumWorld.Environment` can take in response to
     * the actions of one of its agents.
     *
     * These environment actions help form the percepts seen by judges
     * in this environment.
     */
    public enum EnvironmentAction: String {
        case noOp, seeBump, moveAgent, removeDirt, unplugAgent
        public func getValue() -> String { return self.rawValue }
    }
    
    /**
     * What a `Judge` sees in this world.
     */
    public struct JudgePercept {
        let action: EnvironmentAction
        let location: Location // Location _after_ environment processes agent action.
    }
    
    /**
     * Base class for any judge in this world.
     */
    public class AnyJudge: Object, JudgeProtocol {
        // This defines associated types for all judges in this world.
        public func execute(_ percept: JudgePercept) -> Double {
            return 0.0
        }
    }


    // **+****-****+****-****+****-****+****-****+****-****+****-****+****-****
    // --- ENVIRONMENTS ---
    // **+****-****+****-****+****-****+****-****+****-****+****-****+****-****
    
    /**
     * The `VacuumWorld` environment.
     */
    public class Environment: EuclideanEnvironment {

        public var scores = Dictionary<AnyAgent, Dictionary<AnyJudge, Double>>()

        // Compiler wanted these but may be side-effect of other nonsense...
        // These are DEFINED in definition of `scores` below!?
        //public typealias AnyAgent = <#type#>
        //public typealias AnyJudge = <#type#>

        public var space: EuclideanSpace
        public var envObjects = Dictionary<Object, Location>()
        //public var scores = Dictionary<AnyAgent, Dictionary<AnyJudge, Double>>()
        public var views = Set<View<Environment>>()

        /**
         * Initialize a `VacuumEnvironment` with the given `Space`.
         *
         * - Parameter space: The space to use for this environment.
         */
        public init(_ space: EuclideanSpace) {
            // super.init(space)
            self.space = space
        }
        
        /**
         * Map an `AgentAction` to an `EnvironmentAction` or environment change,
         * if any.  These environment changes then become the `Percept`s seen
         * by `Judge`s.
         */
        public func executeAction(_ agent: AnyAgent, _ action: AgentAction) -> [JudgePercept]
        {
            //guard let action = anAction as? AgentAction else {
            //    fatalError("Expected VacuumWorld.AgentAction, got \(anAction).  Aborting")
            //}
            precondition(envObjects[agent] != nil)
            guard let agentLocation = envObjects[agent] else {
                fatalError("Attempt to execute action for nonexistent agent \(agent)?")
            }
            var changes = [JudgePercept]()
            switch action {
            case .moveDown:
                break
            case .moveLeft:
                let newLocation = [agentLocation[0] - 1] + agentLocation[1...]
                if space.contains(newLocation) {
                    envObjects[agent] = newLocation
                    changes.append(JudgePercept(action: .moveAgent, location: newLocation))
                } else {
                    changes.append(JudgePercept(action: .noOp, location: agentLocation))
                }
            case .moveRight:
                let newLocation = [agentLocation[0] + 1] + agentLocation[1...]
                if space.contains(newLocation) {
                    envObjects[agent] = newLocation
                    changes.append(JudgePercept(action: .moveAgent, location: newLocation))
                } else {
                    changes.append(JudgePercept(action: .noOp, location: agentLocation))
                }
            case .moveUp:
                break
            case .noOp:
                break
            case .suck: // Vacuum away all dirt from agent's location.
                let newDictionary = envObjects.filter() { element -> Bool in
                    let (object, location) = element
                    return location != agentLocation || type(of: object) != Dirt.self
                }
                envObjects = newDictionary
                changes.append(JudgePercept(action: .removeDirt, location: agentLocation))
            default:
                break
            } // End switch.
            return changes
        }
        
        /**
         * Synthesize an `AgentPercept` for requesting `Agent`.
         */
        public func getPerceptSeenBy(_ agent: AnyAgent) -> AgentPercept {
            guard let agentLocation = envObjects[agent] else {
                fatalError("Attempt to retrieve percept for nonexistent agent \(agent).")
            }
            let stuff = Set(getObjects(at: agentLocation).keys)
            return AgentPercept(location: agentLocation, objects: stuff)
        }
    }
    
    
    // **+****-****+****-****+****-****+****-****+****-****+****-****+****-****
    // --- AGENTS ---
    // **+****-****+****-****+****-****+****-****+****-****+****-****+****-****
    
    /**
     * This is a simple reflex agent for the two-state vacuum environment.
     *
     * Figure 2.8, AIMA3e, page 48:
     *
     * ```
     * function REFLEX-VACUUM-AGENT([location, status]) returns an action
     *   if status = Dirty then return Suck
     *   else if location = A then return Right
     *   else if location = B then return Left
     * ```
     *
     * A reflex agent (I think) means the agent bases its next decision only on
     * the current percept:  if location is dirty then `Suck`, if location is
     * clean then move away from wall, etc.  A model-based agent adds memory,
     * it remembers which squares are clean and does not waste time rechecking,
     * so it is smarter, scores higher.
     *
     * This reflex agent _function_ may be implemented with a table-based,
     * rule-based, or simple handwritten _program_.
     */
    public class ReflexAgent: AnyAgent {
        
        var ruleBased = false  // Algorithm selector.
        
        /**
         *
         */
        public init(ruleBased: Bool = false) {
            self.ruleBased = ruleBased
        }
        
        /**
         * Initialize a ReflexAgent instance with the REFLEX-VACUUM-AGENT program.
         */
        public override func execute(_ percept: AgentPercept) -> AgentAction {
            
            //guard let percept = scene as? AgentPercept else {
            //    fatalError("Expected VacuumWorld.AgentPercept, got \(scene), aborting.")
            //}
            
            // Make sure we are using the simple two-state world.
            precondition(percept.location == left || percept.location == right)
            
            let isDirty = percept.objects.contains(where: { type(of: $0) == Dirt.self } )
            let state: LocationState = isDirty ? .dirty : .clean
            
            var action: AgentAction = .noOp
            if ruleBased  // Rule-based flavor uses dictionary of dictionaries.
            {
                let rules: [Location: [LocationState: AgentAction]] = [
                    left:  [.clean: .moveRight],
                    left:  [.dirty: .suck],
                    right: [.clean: .moveLeft],
                    right: [.dirty: .suck],
                    ]
                action = rules[percept.location]![state]!
            }
            else          // Algorithm-based variation.
            {
                if isDirty {
                    action = AgentAction.suck
                } else {
                    action = percept.location == left ? .moveRight : .moveLeft;
                }
            }
            return action
        }
    } // End ReflexAgent.
    
    /**
     * A model-based (reflex) agent or at least an agent with some memory.
     * ```
     * function MODEL-BASED-REFLEX-AGENT(percept) returns an action
     *   persistent: state, the agent's current conception of the world state
     *               model, a description of how the next state depends on current state and action
     *               rules, a set of condition-action rules
     *               action, the most recent action, initially none
     *
     *   state  <- UPDATE-STATE(state, action, percept, model)
     *   rule   <- RULE-MATCH(state, rules)
     *   action <- rule.ACTION
     *   return action
     * ```
     * Figure 2.12, AIMA3e, page 51.
     *
     * Adding state to an agent or its program raises a couple of problems
     * with the current design:
     *
     * - Requiring agents to initialize their superclass with their program is
     * bad design; a simple requirement that agents include an `execute()` method
     * is sufficient.  This choice was influenced by a comment on aima-python's
     * Agent suggesting these agent programs might "cheat".  C'mon, really?
     * That's like not letting your hand touch any part of your body.  From now
     * on, the unit of security is the Agent and our Agents (and Judges and
     * Environments) cannot see each other and do not know how the other works.
     *
     * - The other issue was how the first issue introduces memory leaks, which
     * was fixed here with Swift subtleties (also distracts from the subject),
     * and which will be not-a-problem in next design.
     */
    public class ModelBasedAgent: AnyAgent {
        
        /**
         * The instance model.
         */
        var model: [LocationState] = [.unknown, .unknown]
        
        /**
         * An algorithm selector.
         */
        var ruleBased = false
        
        /**
         * This model-based agent program.
         *
         * In order to reference `self` in this closure, we use `lazy` to tell Swift
         * we won't access it until _after_ initialization.  To avoid resulting strong
         * reference cycle, we add capture list `[unowned self]` as described in book's
         * ARC chapter.
         *
         * Swift requires prefix `self.` for instance properties referenced in closures
         * to "remind" us of potential cycles.
         */
        public override func execute(_ percept: AgentPercept) -> AgentAction {
            
            // Begin agent program. Check input for sanity.
            //guard let percept = scene as? AgentPercept else {
            //    fatalError("Expected VacuumWorld.AgentPercept, got \(scene), aborting.")
            //}
            precondition(percept.location == left || percept.location == right)
            let isDirty = percept.objects.contains(where: { type(of: $0) == Dirt.self } )
            let state: LocationState = isDirty ? .dirty : .clean
            
            // Remember state of current location.
            self.model[percept.location == left ? 0 : 1] = state
            
            // Do nothing if every location is clean (this is the new model-based feature).
            if self.model[0] == .clean && self.model[1] == .clean {
                return AgentAction.noOp
            }
            
            // Remainder is like brainless reflex agent above.
            
            var action: AgentAction = .noOp
            if self.ruleBased  // Rule-based flavor uses dictionary of dictionaries.
            {
                let rules: [Location: [LocationState: AgentAction]] = [
                    left:  [.clean: .moveRight],
                    left:  [.dirty: .suck],
                    right: [.clean: .moveLeft],
                    right: [.dirty: .suck],
                    ]
                action = rules[percept.location]![state]!
            }
            else          // Algorithm-based variation.
            {
                if isDirty {
                    action = .suck
                } else {
                    action = percept.location == left ? .moveRight : .moveLeft;
                }
            }
            return action
        }
        
        /**
         * Initialize a ModelBasedAgent with its program.
         *
         * - Parameter ruleBased: Use table of condition-action rules when true;
         *                        otherwise, use manually coded solution.
         */
//        public init(ruleBased: Bool = false) {
//            self.ruleBased = ruleBased
//            super.init()
//            execute = agentProgram // Gross...
//            // print("ModelBasedAgent initialized.")
//        }
//
//        // Used in testMemoryLeak.
//        deinit {
//            // print("ModelBasedAgent deinitialized.")
//        }
        
    } // End ModelBasedAgent.
    
    
    // **+****-****+****-****+****-****+****-****+****-****+****-****+****-****
    // --- JUDGES ---
    // **+****-****+****-****+****-****+****-****+****-****+****-****+****-****
    
    /**
     * Like `ReflexAgent`, `ReflexJudge` has no state (no memory) and returns
     * a score based solely on the last change to the environment.
     */
    public class ReflexJudge: AnyJudge {
        /**
         * Initialize a ReflexJudge instance with a move(-1), suck(+10)
         * performance measure.
         */
        override public func execute(_ percept: JudgePercept) -> Double {
            //guard let percept = scene as? JudgePercept else {
            //    fatalError("Expected VacuumWorld.JudgePercept, got \(scene), aborting.")
            //}
            var score = 0.0
            switch percept.action {
            case .noOp:
                score = 0.0 // Is agent smart or lazy or did it just bump into a wall?
            case .moveAgent:
                score = -1
            case .removeDirt:
                score = +10
            default:
                break
            }
            return score
        }
    } // End ReflexJudge.
    
} // End VacuumWorld namespace.
