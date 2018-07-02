Contributing to this project
==========================
:+1::tada: Yes! :tada::+1:

I'm new to open source (and github and swift and ...) so will be fumbling along here, 
completing AIMA Chapter 2, and welcome all contributions, pull requests, advice,
moral support, and expresso.  Here are scattered notes on state of the art.

Documentation and modeling borrow from [aima-python](https://github.com/aimacode/aima-python) 
and [aima-java](https://github.com/aimacode/aima-java) (thanks, guys).

## Coding and Design

- In general, imitate [Swift authors](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html) 
and add tips here that you find.

- For Xcode Quick Help (i.e., the circled question mark in upper right of IDE), select a type or function or variable
and press **Command+Option+/** to generate a template above the item, then fill in the template.  This Quick Help
shows up to everyone anywhere when they hover over your item.  See [the hipster](http://nshipster.com/swift-documentation/) for more techniques; it appears to be a mix of javadoc and markdown syntax.

- Browse [aima-java](https://github.com/aimacode/aima-java) documentation to see what is possible.

- Unlike C++ namespaces or Java packages, Swift's default scope for names appears to be the entire
(often large) distributable module.  In our case, this means the `AImaKit` framework, the thing that is
built and then used via `import AImaKit`, is one gigantic flat namespace.  Since `AImaKit` may contain
many different task environments, each with its own flavor of `Agent`, `Percept`, `Action`, and so on,
this is a problem.
Scrolling down a page like [this](https://developer.apple.com/documentation/swift/equatable)
suggests that Apple prefixes global names with acronyms like `CF`, `NS`, or `UI` so that importing both 
`Foundation` and `UIKit` might leave you with (a bizillion) names `CFAction` and `UIAction` but the 
modules don't collide.  Still, the large number of names that these Apple frameworks introduce can feel 
daunting; here is an alternate solution:

`AImaKit` currently has a topmost file `Agents.swift` that may be renamed to `Model.swift`.  It defines
important AIMA nouns as abstractly as I am currently able in Swift.  So it defines `IAction`, `IPercept`, etc.,
where the '`I`' means these are _like_ Java interfaces; they are meant to be subclassed by different task
environments.

`VacuumWorld.swift` is a task environment that looks like this,
```swift
public class VacuumWorld { // Begin VacuumWorld task environment.

  public enum Action: IAction { blah }
  public struct Percept: IPercept { blah }
  public class Environment: IEnvironment { blah }
  public class ReflexAgent: IAgent { blah }
  public class AnotherAgent: IAgent { blah } // Another vacuum world agent type.
  . . .

} // End VacuumWorld namespace.
```
So the names are all simple inside the task environment and multiple task environments don't collide
because their surrounding class (`VacuumWorld` in this case) provides the local namespace.  In tests
or applications using `AImaKit`, you can then define acronyms as needed and are not unwillingly 
bombarded with all of them.  For example, in `AImaKitTest.swift`, a test looks like this,
```swift
typealias VW = VacuumWorld
let environment = VW.Environment(...)
let agent = VW.ReflexAgent()
environment.addObject(agent, at: VW.right)
environment.addObject(Dirt(), at: VW.left)
etc...
```
So we'll use that until it doesn't work.  ThisLongRunOnNote probably needs a wiki page...

## Issues
- Finish chapter 2.
- Figure out how Apple builds frameworks from command line and implement.
- Add GUI's, perhaps separate projects that reference AImaKit.
- Learn how to distribute a properly signed AImaKit binary for users who prefer to focus on AIMA rather
than Swift.
- And so on... 
