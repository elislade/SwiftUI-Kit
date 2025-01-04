import SwiftUI


public extension Font {
    
    static func modifier(for trait: FontTrait) -> FontModifier {
        switch trait {
        case .italic: .italic
        case .smallCaps: .smallCaps
        case .smallCapsUppercase: .smallCapsUpper
        case .smallCapsLowercase: .smallCapsLower
        case .monospacedDigit: .monospacedDigit
        case .monospaced: .monospaced
        }
    }
    
    func traits<Traits: Collection>(_ traits: Traits) -> Font where Traits.Element == FontTrait {
        traits.reduce(into: self){ font, trait in
            font = Self.modifier(for: trait).modify(font: font)
        }
    }
    
    func traits(_ traits: FontTrait...) -> Font {
        traits.reduce(into: self){ font, trait in
            font = Self.modifier(for: trait).modify(font: font)
        }
    }
    
    func trait(_ trait: FontTrait) -> Font {
        traits(trait)
    }
    
    subscript(trait: FontTrait) -> Font {
        self.trait(trait)
    }
    
}
