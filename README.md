# ![](https://github.com/aimacode/aima-java/blob/gh-pages/aima3e/images/aima3e.jpg)aima-swift

> "Houston, we have a vacuum cleaner."

In the spirit of [aimacode](https://github.com/aimacode/), this project aims toward a [Swift](https://swift.org) 
implementation of algorithms from [Russell](http://www.cs.berkeley.edu/~russell/) and [Norvig's](http://www.norvig.com/) 
[Artificial Intelligence - A Modern Approach 3rd Edition](http://aima.cs.berkeley.edu/).

## Getting Started
Until a manual build is available, please use a recent Xcode + Swift.  I'm using Xcode v9.4.1 and Swift v4.1.2
but may soon upgrade to v10 so that internet documentation matches local behavior.

To download the repository:

`git clone https://github.com/iDave2/aima-swift.git`

To more easily find what Xcode builds, try File > Project Settings and place DerivedData relative to your
project (i.e., in its root).  If you cloned the repository to, say, `~/russell-norvig` then an alias like this,

`alias swift="swift -F ~/russell-norvig/DerivedData/AImaKit/Build/Products/Debug"`

tells Swift where to find the AImaKit framework and lets you easily run tests from a command line.  For example,

```bash
$ cat test.swift 
import AImaKit

let agent = ReflexVacuumAgent()
let percept = LocalVacuumPercept(location: .left, state: .dirty)
let action = agent.execute(percept)
print("Agent sees \(percept), does \"\(action).\"")
``` 

Additional unit tests are available in Xcode target `AImaKitTests`.

Happy Swifting!
