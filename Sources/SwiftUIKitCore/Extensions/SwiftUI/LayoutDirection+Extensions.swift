import SwiftUI


extension LayoutDirection {
    
    nonisolated public var inverse: LayoutDirection {
        switch self {
        case .leftToRight: .rightToLeft
        case .rightToLeft: .leftToRight
        @unknown default: .rightToLeft
        }
    }
    
    nonisolated public var scaleFactor: CGFloat {
        self == .rightToLeft ? -1 : 1
    }
    
    nonisolated public init(languageCode code: Locale.LanguageCode) {
        self = {
            let rtl: Set<Locale.LanguageCode> = [
                .arabic, .azerbaijani, .dhivehi, .hebrew, .kurdish, .persian, .urdu
            ]
            return rtl.contains(code) ? .rightToLeft : .leftToRight
        }()
    }
    
}
