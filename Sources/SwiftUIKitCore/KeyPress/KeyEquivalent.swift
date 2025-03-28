

public struct KeyEquivalent : Hashable, Sendable {

    /// Up Arrow (U+F700)
    public static let upArrow = KeyEquivalent("\u{F700}")

    /// Down Arrow (U+F701)
    public static let downArrow = KeyEquivalent("\u{F701}")

    /// Left Arrow (U+F702)
    public static let leftArrow = KeyEquivalent("\u{F702}")

    /// Right Arrow (U+F703)
    public static let rightArrow = KeyEquivalent("\u{F703}")

    /// Escape (U+001B)
    public static let escape = KeyEquivalent("\u{001B}")

    /// Delete (U+0008)
    public static let delete = KeyEquivalent("\u{0008}")

    /// Delete Forward (U+F728)
    public static let deleteForward = KeyEquivalent("\u{F728}")

    /// Home (U+F729)
    public static let home = KeyEquivalent("\u{F729}")

    /// End (U+F72B)
    public static let end = KeyEquivalent("\u{F72B}")

    /// Page Up (U+F72C)
    public static let pageUp = KeyEquivalent("\u{F72C}")

    /// Page Down (U+F72D)
    public static let pageDown = KeyEquivalent("\u{F72D}")

    /// Clear (U+F739)
    public static let clear = KeyEquivalent("\u{F739}")

    /// Tab (U+0009)
    public static let tab = KeyEquivalent("\u{0009}")

    /// Space (U+0020)
    public static let space = KeyEquivalent("\u{0020}")

    /// Return (U+000D)
    public static let `return` = KeyEquivalent("\u{000D}")

    /// The character value that the key equivalent represents.
    public var character: Character

    /// Creates a new key equivalent from the given character value.
    public init(_ character: Character){
        self.character = character
    }
    
}


extension KeyEquivalent : ExpressibleByExtendedGraphemeClusterLiteral {
    
    /// Creates an instance initialized to the given value.
    ///
    /// - Parameter value: The value of the new instance.
    public init(extendedGraphemeClusterLiteral literal: Character){
        self.init(literal)
    }
    
}
