import SwiftUI


public extension LayoutDirection {
    
    var inverse: LayoutDirection {
        switch self {
        case .leftToRight: .rightToLeft
        case .rightToLeft: .leftToRight
        @unknown default: .rightToLeft
        }
    }
    
    var scaleFactor: CGFloat {
        self == .rightToLeft ? -1 : 1
    }
    
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    init(languageCode code: Locale.LanguageCode) {
        self = {
            let rtl: Set<Locale.LanguageCode> = [
                .arabic, .azerbaijani, .dhivehi, .hebrew, .kurdish, .persian, .urdu
            ]
            return rtl.contains(code) ? .rightToLeft : .leftToRight
        }()
    }
    
}
