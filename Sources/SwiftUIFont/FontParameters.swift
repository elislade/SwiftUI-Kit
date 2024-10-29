import Foundation
import SwiftUI


/// A set of parameters used to resolve a `Font`.
/// - Note: These  parameters are suggestions for the ``ResolvedFont``, if the ``FontAsset`` being resolved does not support a parameter it will ignore it.
public struct FontParameters: Codable, Hashable, Sendable {
    
    /// Base identity is of a font with 16point size, standard width, regular weight, no slant and a transform of `.identity`.
    public static let identity = FontParameters()
    
    
    /// A set of symbolic traits for the font.
    public var traits: Set<Font.Trait> = []
    
    /// -1 is most compact, 0 is normal/regular and 1 is widest.
    public var width: Double = 0
    
    /// -1 is lightest weight, 0 is normal/regular and 1 is heaviest.
    public var weight: Double = 0
    
    /// Size in points.
    public var size: Double = 16
    
    /// -1 is slanted to the left up to -30deg, 0 is not slanted at all and 1 is slanted up-to 30 deg to the right.
    /// - Note: A slant of more than 0 or 1 is usually equivilent to an italic trait.
    public var slant: Double = 0
    
    /// A transform to applied to every glyph.
    public var transform: CGAffineTransform = .identity
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(traits)
        hasher.combine(width)
        hasher.combine(weight)
        hasher.combine(size)
        hasher.combine(slant)
    }
    
    public func copy<V>(replacing key: WritableKeyPath<Self, V>, with value: V) -> Self {
        var copy = self
        copy[keyPath: key] = value
        return copy
    }
    
    public func copy<V>(replacing keys: WritableKeyPath<Self, V>..., from other: Self) -> Self {
        var copy = self
        for key in keys {
            copy[keyPath: key] = other[keyPath: key]
        }
        return copy
    }
    
    public subscript(weight: Font.Weight) -> Self {
        copy(replacing: \.weight, with: weight.value)
    }
    
    public subscript(style: Font.TextStyle) -> Self {
        copy(replacing: \.size, with: style.baseSize)
    }
    
    public subscript(trait: Font.Trait) -> Self {
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
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public subscript(width: Font.Width) -> Self {
        copy(replacing: \.width, with: width.value)
    }
    
}


protocol FontParametersModifier {
    
    func modify(_ parameters: inout FontParameters)
    
}



struct FontParametersKey: EnvironmentKey {
    
    static var defaultValue: FontParameters = .init()
    
}



public extension EnvironmentValues {
    
    var fontParameters: FontParameters {
        get { self[FontParametersKey.self] }
        set { self[FontParametersKey.self] = newValue }
    }
    
    var fontResolved: ResolvedFont {
        fontResource.resolve(with: fontParameters, in: self)
    }
    
    var fontResourceFont: Font {
        fontResolved.opaqueFont
    }
    
}
