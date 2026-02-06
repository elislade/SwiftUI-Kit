import SwiftUI

@available(*, deprecated, renamed: "BlurEffectView")
public typealias VisualEffectView = BlurEffectView

public struct BlurEffectView {

    public struct Filters: OptionSet, Sendable {
        
        public let rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        public static let sdrNormalize      = Filters(rawValue: 1 << 0)
        public static let luminanceCurveMap = Filters(rawValue: 1 << 1)
        public static let colorSaturate     = Filters(rawValue: 1 << 2)
        public static let colorBrightness   = Filters(rawValue: 1 << 3)
        public static let gaussianBlur      = Filters(rawValue: 1 << 4)
        
        public static var color: Self { [.colorSaturate, .colorBrightness] }
        public static var nonBlur: Self { [.color, .luminanceCurveMap, .sdrNormalize] }
        
    }
    
    let filtersDisabled: Filters
    let blurRadius: Double?
    
    /// Initializes a representation
    /// - Note: Values may only take effect on initialization and will not update consistently after. If you want to update values live you will have to change the identity of the representation on every value change, which will teardown and setup this view.
    ///
    /// - Parameters:
    ///   - filtersDisabled: A set of filters to disable from the available filters applied. Not all filters are guarenteed to exist depending on platform, system color scheme, and accessibility features enabled. Defaults to all filters except `gaussianBlur`.
    ///   - blurRadius: If blur filter is not disabled, this will set its value. Defaults to nil which will use system defaults.
    public init(
        filtersDisabled: Filters = .nonBlur,
        blurRadius: Double? = nil
    ) {
        self.filtersDisabled = filtersDisabled
        self.blurRadius = blurRadius
    }
    
}


#if os(watchOS)

extension BlurEffectView: View {
    
    public var body: some View {
        Rectangle().fill(.regularMaterial)
    }
    
}

#endif


extension BlurEffectView.Filters {
    
    func update(filters: [NSObject], blurRadius: Double? = nil) {
        for filter in filters {
            let name = filter.value(forKey: "name") as! String
            switch name {
            case "sdrNormalize":
                filter.setValue(!contains(.sdrNormalize), forKey: "enabled")
            case "luminanceCurveMap":
                filter.setValue(!contains(.luminanceCurveMap), forKey: "enabled")
            case "colorSaturate":
                filter.setValue(!contains(.colorSaturate), forKey: "enabled")
            case "colorBrightness":
                filter.setValue(!contains(.colorBrightness), forKey: "enabled")
            case "gaussianBlur":
                filter.setValue(!contains(.gaussianBlur), forKey: "enabled")
                filter.setValue(blurRadius ?? 30, forKey: "inputRadius")
            default: continue
            }
        }
    }
    
}
