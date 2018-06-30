Contributing to this project
==========================
:+1::tada: Yes! :tada::+1:

I'm new to open source (and github and swift and ...) so will be fumbling along here, 
completing AIMA Chapter 2, and welcome all contributions whether you are also learning
or are an expert with good tips (or both).  Here are scattered notes on state of the art.

Documentation and modeling borrow from aima-python and aima-java (thanks, guys).

## Coding Guidelines
In general, imitate [Swift authors](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html) 
and add tips here that you find.

### Documentation
- For Xcode Quick Help (i.e., the circled question mark in upper right of IDE), select a type or function or variable
and press **Command+Option+/** to generate a template above the item, then fill in the template.  This Quick Help
shows up to everyone anywhere when they hover over your item.  See [the hipster](http://nshipster.com/swift-documentation/) for more techniques, it appears to be a mix of javadoc and markdown syntax.
- Browse [aima-java](https://github.com/aimacode/aima-java) documentation to see what is possible.

## Issues
- Figure out how Apple builds frameworks from command line and implement.
- Add GUI's, perhaps separate projects that reference AImaKit.
- Learn how to distribute a properly signed AImaKit binary for users who prefer to focus on AIMA rather
than Swift.
- Find out how to simulate more granular namespaces in the big flat framework so that a larger collection
of Task Environments don't interfere with each other.
- And so on... 
