import SwiftUI

/// A way to customize VisualEffectView.
@MainActor public struct VisualEffectView {

    public enum Filter: UInt8, CaseIterable, Identifiable, Sendable, LosslessStringConvertible {
        public var id: RawValue { rawValue }
        
        case sdrNormalize
        case luminanceCurveMap
        case colorSaturate
        case colorBrightness
        case gaussianBlur
        
        public init?(_ description: String) {
            guard let match = Self.allCases.first(where: { $0.description == description })
            else { return nil }
            self = match
        }
        
        public var description: String {
            switch self {
            case .sdrNormalize: "sdrNormalize"
            case .luminanceCurveMap: "luminanceCurveMap"
            case .colorSaturate: "colorSaturate"
            case .colorBrightness: "colorBrightness"
            case .gaussianBlur: "gaussianBlur"
            }
        }
        
    }
    
    let disableFilters: Set<Filter>
    let blurRadius: Double?
    
    /// Initializes a representation
    /// - Note: Values only take effect on initalization and will not update consistently after. If you want to update values live you will have to change the identity of the representation on every value change, which will teardown and setup this view.
    /// 
    /// - Parameters:
    ///   - disableFilters: A set of filters to disable from the available filters applied. Not all filters are guarenteed to exist depending on platform, system color scheme, and accessibility features enabled like high contrast. Defaults to a set of all filters except `gaussianBlur`.
    ///   - blurRadius: If blur filter is not disabled, this will set its value. Defaults to nil which will use system defaults. System defaults are 29.5 on iOS 17 and 30 on macOS 14.
    public init(
        disableFilters: Set<Filter> = Set(Filter.allCases).subtracting([.gaussianBlur]),
        blurRadius: Double? = nil
    ) {
        self.disableFilters = disableFilters
        self.blurRadius = blurRadius
    }
    
}


#if os(watchOS)

extension VisualEffectView: View {
    
    public var body: some View {
        Rectangle().fill(.regularMaterial)
    }
    
}

#endif
