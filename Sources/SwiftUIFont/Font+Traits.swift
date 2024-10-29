import SwiftUI


public extension Font {
    
    enum Trait: Int, Hashable, Sendable, Codable, CaseIterable {
        case italic = 0
        case smallCaps = 1
        case smallCapsUppercase = 2
        case smallCapsLowercase = 3
        case monospaced = 4
        case monospacedDigit = 5
    }
    
    static func modifier(for trait: Trait) -> FontModifier {
        switch trait {
        case .italic: .italic
        case .smallCaps: .smallCaps
        case .smallCapsUppercase: .smallCapsUpper
        case .smallCapsLowercase: .smallCapsLower
        case .monospacedDigit: .monospacedDigit
        case .monospaced: .monospaced
        }
    }
    
    func traits<Traits: Collection>(_ traits: Traits) -> Font where Traits.Element == Trait {
        traits.reduce(into: self){ font, trait in
            font = Self.modifier(for: trait).modify(font: font)
        }
    }
    
    func traits(_ traits: Trait...) -> Font {
        traits.reduce(into: self){ font, trait in
            font = Self.modifier(for: trait).modify(font: font)
        }
    }
    
    func trait(_ trait: Trait) -> Font {
        traits(trait)
    }
    
    subscript(trait: Trait) -> Font {
        self.trait(trait)
    }
    
}
