//
//  Object.swift
//  AImaKit
//
//  Created by Dave King on 6/23/18.
//

/**
 * Named in honor of Java's `Object`, this superclass provides a default
 * equivalence relation and hash code for any Swift types you want to use
 * in a `Collection` (like `Array` or `Set`).  Subclasses may override
 * default implementations as needed.
 */
public class Object: Hashable {

  // Explicitly increase access level from default 'internal' to 'public'.
  public init() { }
  
  // Two object or instance references are equal if and only if they point to
  // the same address, the same memory.
  public static func == (lhs: Object, rhs: Object) -> Bool {
    return lhs === rhs
  }
  
  // These hash values also use address-like discrimination.
  public var hashValue: Int { return ObjectIdentifier(self).hashValue }
}
