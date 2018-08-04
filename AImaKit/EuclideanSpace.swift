//
//  EuclideanSpace.swift
//  AImaKit
//
//  Created by Dave King on 8/2/18.
//

import Foundation

/**
 * For problems involving N-dimensional Cartesian locations, it is simpler to
 * implement one concrete model than multiple custom spaces like `(left, right)`
 * and is arguably clearer.
 *
 * This class models an N-dimensional `Space` of integer coordinates where
 * `N >= 0`.  Each dimension is initialized with a half-open interval, or
 * `Range`, like `0..<10` or `-5..<5`.  A `Location` then is just an array
 * of integers.
 *
 * The default initializer generates the special case of `N = 0` and permits
 * expressions like
 * ```swift
 * let mySpace = Space()
 * ```
 * which gives you a concrete representation of nothing (in case you
 * are working on big bang theory).
 */
public class EuclideanSpace {
    let ranges: [Range<Int>]

    /**
     * Method initializes `Space` instance with zero or more `Range`s.
     *
     * - Parameters:
     *     - ranges: The list of ranges, one per dimension.
     */
    public init(_ ranges: Range<Int>...) {
        self.ranges = ranges
    }

    /**
     * - Returns: The number of dimensions of this space (i.e., the number of
     *            ranges supplied at initialization).
     */
    public func getDimension() -> Int { return ranges.count }

    /**
     * Method checks whether a given `Location` is _inside_ this `Space`.
     *
     * A `location` is _inside_ iff it's dimension is no greater than the `Space`'s
     * and each of its coordinates is contained in the corresponding `Space` range.
     *
     * - Parameter location: The `Location` to test for containment.
     * - Returns: True if `location` is inside this `Space`; otherwise, false.
     */
    public func contains(_ location: Location) -> Bool {
        //
        // Does nothing contain nothing?
        //
        if ranges.isEmpty || location.isEmpty {
            return false
        }
        //
        // The relation is `contains`, not `intersects`.
        //
        if ranges.count < location.count {
            return false
        }
        //
        // Check each coordinate for containment.
        //
        for i in 0 ..< min(ranges.count, location.count) {
            if !ranges[i].contains(location[i]) {
                return false
            }
        }
        return true
    }

    /**
     * Returns: A random location inside the space.
     */
    public func randomLocation() -> Location {
        var location = [Int]()
        for range in ranges {
            location.append(Int.random(in: range))
        }
        return location
    }

    /**
     * Generate a model of this space initialized with the given value.
     *
     * There are no doubt better ways to do this but, for now, here is
     * an example of usage:
     * ```
     * let space = Space(0..<3, 0..<2, 0..<1)  // That's 3x2x1 cuboid.
     * guard let array = space.toArray(repeating: "unknown") as? [[[String]]] else {
     *   fatalError("Cannot construct array from space \(space).")
     * }
     * print("let array: [[[String]]] =", array)
     * ```
     *
     * - Parameter repeating: The value to initialize array with.
     * - Returns: An N-dimensional array initialized with incoming element
     *            or nil if Space is Nothing or something else failed.
     */
    public func toArray<Element>(repeating: Array<Element>.Element) -> AnyObject? {
        if ranges.isEmpty {
            return nil
        }
        var backward = ranges
        backward.reverse()           // Why must this be "in place?" Odd.
        var any = repeating as Any   // Any's type will keep changing.
        for range in backward {
            any = Array(repeating: any, count: range.count) as AnyObject
        }
        return any as AnyObject
    }
}
