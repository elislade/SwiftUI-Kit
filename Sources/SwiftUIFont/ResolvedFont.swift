import SwiftUI


/// A Font that has been resolved
@dynamicMemberLookup public struct ResolvedFont: Hashable, Sendable {

    /// The set up parameters used to resolve this font.
    public let parameters: FontParameters
    
    /// The opaqueFont that was resolved.
    public let opaqueFont: Font
    
    /// Info about the resolved font.
    public let info: FontInfo
    
    /// Metrics about the resolved font.
    public let metrics: FontMetrics
    
    public init(parameters: FontParameters, opaqueFont: Font, info: FontInfo, metrics: FontMetrics) {
        self.parameters = parameters
        self.opaqueFont = opaqueFont
        self.info = info
        self.metrics = metrics
    }
    
}


public extension ResolvedFont {
    
    /// Convenience for accessing ``FontInfo``.
    subscript<T>(dynamicMember key: KeyPath<FontInfo, T>) -> T {
        info[keyPath: key]
    }
    
    
    /// Convenience for accessing ``FontMetrics``.
    subscript<T>(dynamicMember key: KeyPath<FontMetrics, T>) -> T {
        metrics[keyPath: key]
    }
    
}
