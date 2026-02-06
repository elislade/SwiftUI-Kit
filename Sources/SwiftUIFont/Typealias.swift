

#if canImport(SwiftUI)

import SwiftUI
public typealias OpaqueFont = SwiftUI.Font
public typealias FontTransform = CGAffineTransform
public typealias FontURL = SwiftUI.URL

#else

public typealias OpaqueFont = Never
public typealias FontTransform = Never
public typealias FontURL = Never

#endif


#if canImport(UIKit)

public typealias OSFont = UIFont
public typealias OSFontDescriptor = UIFontDescriptor

#elseif canImport(AppKit)

public typealias OSFont = NSFont
public typealias OSFontDescriptor = NSFontDescriptor

extension NSFont {
    
    public convenience init(descriptor: NSFontDescriptor, size: CGFloat) {
        self.init(descriptor: descriptor, size: size)!
    }
    
}

#else

public typealias OSFont = Never
public typealias OSFontDescriptor = Never

#endif


extension CTFont {
    
    nonisolated public static func system(
        _ size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> CTFont {
        let desc = OSFont
            .systemFont(ofSize: size, weight: weight.osWeight)
            .fontDescriptor.withDesign(design.osDesign)!
        return CTFont(desc, size: 0)
    }
    
}

extension Font.Weight {
    
    nonisolated public var osWeight: OSFont.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
    
}


extension Font.Design {
    
    nonisolated public var osDesign: OSFontDescriptor.SystemDesign {
        switch self {
        case .default: return .default
        case .monospaced: return .monospaced
        case .serif: return .serif
        case .rounded: return .rounded
        default: return .default
        }
    }
    
}


extension OffsetShape: @retroactive Equatable {
    
    public static func == (lhs: OffsetShape, rhs: OffsetShape) -> Bool {
        return lhs.offset == rhs.offset
    }
    
}
