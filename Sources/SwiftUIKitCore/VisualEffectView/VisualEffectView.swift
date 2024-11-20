import SwiftUI

/// A way to customize VisualEffectView. Note that values only take effect on initalization and will not update consistently after. If you want to update values live you will have to change the identity of the representation on every value change, which will teardown and setup this view.
@MainActor public struct VisualEffectView {

    public enum Filter: String, CaseIterable, Identifiable, Sendable {
        public var id: String { rawValue }
        
        case sdrNormalize
        case luminanceCurveMap
        case colorSaturate
        case colorBrightness
        case gaussianBlur
    }
    
    let disableFilters: Set<Filter>
    let blurRadius: CGFloat?
    
    /// Initializes a representation
    /// - Parameters:
    ///   - disableFilters: A set of filters to disable from the available filters applied. Not all filters are guarenteed to exist depending on platform, system color scheme, and accessibility features enabled like high contrast. Defaults to a set of all filters except `gaussianBlur`.
    ///   - blurRadius: If blur filter is not disabled, this will set its value. Defaults to nil which will use system defaults. System defaults are 29.5 on iOS 17 and 30 on macOS 14.
    public init(
        disableFilters: Set<Filter> = Set(Filter.allCases).subtracting([.gaussianBlur]),
        blurRadius: CGFloat? = nil
    ) {
        self.disableFilters = disableFilters
        self.blurRadius = blurRadius
    }
    
}
