import SwiftUI


public protocol FontModifier {
    func modify(font: Font) -> Font
}

public final class AnyFontModifier: FontModifier {
    
    let base: Any
    
    public init<B: FontModifier>(_ base: B) {
        self.base = base
    }
    
    public func modify(font: Font) -> Font {
        (base as! FontModifier).modify(font: font)
    }
    
}

public extension Font {
    
    func modify(_ modifier: FontModifier) -> Font {
        modifier.modify(font: self)
    }
    
}


// - MARK: Empty


public struct EmptyFontModifier: FontModifier {
    
    public func modify(font: Font) -> Font { font }
    
}

public extension FontModifier where Self == EmptyFontModifier {
    
    /// Does not modify the font.
    static var empty: EmptyFontModifier { EmptyFontModifier() }
}


// - MARK: Italic


public struct ItalicFontModifier: FontModifier {
    
    public func modify(font: Font) -> Font {
        font.italic()
    }
    
}


public extension FontModifier where Self == ItalicFontModifier {
    
    /// Modifies font with italic styling
    static var italic: ItalicFontModifier { ItalicFontModifier() }
    
}


// - MARK: Small Caps


public struct SmallCapsFontModifier: FontModifier {
    
    var textCase : Text.Case?
    
    init(_ textCase: Text.Case? = nil) {
        self.textCase = textCase
    }
    
    public func modify(font: Font) -> Font {
        if let textCase {
            switch textCase {
            case .uppercase: font.uppercaseSmallCaps()
            case .lowercase: font.lowercaseSmallCaps()
            @unknown default: font.smallCaps()
            }
        } else {
            font.smallCaps()
        }
    }
    
}


public extension FontModifier where Self == SmallCapsFontModifier {
    
    static var smallCaps: SmallCapsFontModifier { .init() }
    static var smallCapsUpper: SmallCapsFontModifier { .init(.uppercase) }
    static var smallCapsLower: SmallCapsFontModifier { .init(.lowercase) }
    
}


// - MARK: Monospaced


public struct MonospacedFontModifier: FontModifier {
    
    var onlyDigit: Bool = false
    
    public func modify(font: Font) -> Font {
        if onlyDigit {
            font.monospacedDigit()
        } else {
            font.monospaced()
        }
    }
    
}


public extension FontModifier where Self == MonospacedFontModifier {
    
    static var monospacedDigit: MonospacedFontModifier { .init(onlyDigit: true) }
    static var monospaced: MonospacedFontModifier { .init(onlyDigit: false) }
    
}


// - MARK: Weight


public struct FontWeightModifier: FontModifier {
    let weight: Font.Weight

    public func modify(font: Font) -> Font {
        font.weight(weight)
    }
}

public extension FontModifier where Self == FontWeightModifier {
    
    static func weight(_ weight: Font.Weight) -> FontWeightModifier {
        .init(weight: weight)
    }
    
}


// - MARK: Width


public struct FontWidthModifier: FontModifier {
    let width: CGFloat
    
    init(width: CGFloat) {
        self.width = width
    }

    public func modify(font: Font) -> Font {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            font.width(.init(width))
        } else {
            font
        }
    }
    
}


public extension FontModifier where Self == FontWidthModifier {
    
    static func width(_ width: CGFloat) -> FontWidthModifier {
        FontWidthModifier(width: width)
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    static func width(_ width: Font.Width) -> FontWidthModifier {
        FontWidthModifier(width: width.value)
    }
    
}


// - MARK: Leading


public struct FontLeadingModifier: FontModifier {
    let leading: Font.Leading
    
    init(leading: Font.Leading) {
        self.leading = leading
    }

    public func modify(font: Font) -> Font {
        font.leading(leading)
    }
}


public extension FontModifier where Self == FontLeadingModifier {
    
    static func leading(_ value: Font.Leading) -> FontLeadingModifier {
        .init(leading: value)
    }
    
}
