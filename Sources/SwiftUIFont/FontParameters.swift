import CoreFoundation.CFCGTypes


/// A set of parameters used to resolve a `Font`.
/// - Note: These  parameters are suggestions for the ``ResolvedFont``, if the ``FontResource`` being resolved does not support a parameter it will ignore it.
public struct FontParameters: Codable, Hashable, Sendable {
    
    /// Base identity is of a font with 16 point size, standard width, regular weight, no slant and a transform of `.identity`.
    public static let identity = FontParameters()
    
    
    /// A set of symbolic traits for the font.
    public var traits: Set<FontTrait> = []
    
    /// -1 is most compact, 0 is normal/regular and 1 is widest.
    public var width: Double = 0
    
    /// -1 is lightest weight, 0 is normal/regular and 1 is heaviest.
    public var weight: Double = 0
    
    /// Size in points.
    public var size: Double = 16
    
    /// -1 is slanted to the left up to -30deg, 0 is not slanted at all and 1 is slanted up-to 30 deg to the right.
    /// - Note: A slant of more than 0 or 1 is usually equivilent to an italic trait.
    public var slant: Double = 0
    
    /// A transform to apply to every glyph.
    public var transform: FontTransform = .identity
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(traits)
        hasher.combine(width)
        hasher.combine(weight)
        hasher.combine(size)
        hasher.combine(slant)
    }
    
    public nonisolated func copy<V>(replacing key: WritableKeyPath<Self, V>, with value: V) -> Self {
        var copy = self
        copy[keyPath: key] = value
        return copy
    }
    
    public nonisolated func copy<V>(replacing keys: WritableKeyPath<Self, V>..., from other: Self) -> Self {
        var copy = self
        for key in keys {
            copy[keyPath: key] = other[keyPath: key]
        }
        return copy
    }
    
    public nonisolated subscript(trait: FontTrait) -> Self {
        if traits.contains(trait){
            return self
        } else if trait == .italic {
            return copy(replacing: \.slant, with: 1)
        } else {
            var traits = self.traits
            traits.insert(trait)
            return copy(replacing: \.traits, with: traits)
        }
    }
    
}


protocol FontParametersModifier {
    
    func modify(_ parameters: inout FontParameters)
    
}
