# ![](https://github.com/aimacode/aima-java/blob/gh-pages/aima3e/images/aima3e.jpg)aima-swift

> "Houston, we have a vacuum cleaner."

In the spirit of [aimacode](https://github.com/aimacode/), this project aims toward a [Swift](https://swift.org) 
implementation of algorithms from [Russell](http://www.cs.berkeley.edu/~russell/) and [Norvig's](http://www.norvig.com/) 
[Artificial Intelligence - A Modern Approach 3rd Edition](http://aima.cs.berkeley.edu/).

## Getting Started
The project uses Xcode 10 and Swift 4.2 which are Beta at time of writing.  You can download Xcode Beta
releases from [this page](https://developer.apple.com/support/beta-software/).  The download unzips into
`Xcode-beta.app` and includes the newer `Swift` in its toolchain.  In order to activate newer `Swift`
everywhere, either use [xcode-select](http://iosdevelopertips.com/xcode/xcode-select-managing-multiple-versions-of-xcode.html)
or run Preferences > Locations from the `Xcode-beta` IDE and select it as the location for Command Line Tools.
Then `Swift` is magically v4.2 everywhere.

To download the repository:

`git clone https://github.com/iDave2/aima-swift.git`

To more easily find what Xcode builds, try File > Project Settings and place DerivedData relative to your
project (i.e., in its root).  If you cloned the repository to, say, `~/russell-norvig` then an alias like this,

`alias swift="swift -F ~/russell-norvig/DerivedData/AImaKit/Build/Products/Debug"`

tells Swift where to find the AImaKit framework and lets you easily run tests from a command line.  For example,

```bash
$ cat test.swift 
import AImaKit
  
typealias VW = VacuumWorld

let agent = VW.ReflexAgent() // Create an agent.
let stuff = Set<EnvironmentObject>([VW.Dirt()]) // Create one dirt. 
let percept = VW.AgentPercept(location: VW.left, objects: stuff) // One dirt?
let action = agent.execute(percept) // Give me one dirt, Vasili.
print("Agent sees \(percept), does \"\(action).\"")
``` 

Additional unit tests are available in Xcode target `AImaKitTests`.

Happy Swifting!
