import Foundation
import SwiftUI


struct SwiftUIFontResolver: FontResolver {
    
    func resolve(resource: FontResource, with parameters: FontParameters) -> ResolvedFont {
        var font: Font = .system(.body)
        
        if let design = resource.design {
            font = .system(size: parameters.size, design: design)
        } else if let name = resource.familyName {
            font = .custom(name, size: parameters.size)
        }
        
        font = font.traits(parameters.traits)
        
        //let modifiers = parameters.traits.map{ }
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            font = font.width(.init(parameters.width))
        }
        
        return ResolvedFont(
            parameters: parameters,
            opaqueFont: font.weight(.init(closestToValue: parameters.weight)),
            info: .init(), // Info is unavailable to SwiftUI resolver.
            metrics: .zero // Metrics is unavailable to SwiftUI resolver.
        )
    }
    
}


struct FontResolverKey: EnvironmentKey {
    
    static var defaultValue: FontResolver { SwiftUIFontResolver() }
    
}


extension EnvironmentValues {
    
    var fontResolver: FontResolver {
        get { self[FontResolverKey.self] }
        set { self[FontResolverKey.self] = newValue }
    }
    
    public var resolvedFont: ResolvedFont {
        #if canImport(UIKit)
        let content = UIContentSizeCategory(sizeCategory)
        let trait = UITraitCollection(preferredContentSizeCategory: content)
        let dynamicSize = UIFontMetrics.default.scaledValue(for: fontParameters.size, compatibleWith: trait)
        #else
        let dynamicSize = fontParameters.size
        #endif
        
        let parameters = fontParameters.copy(replacing: \.size, with: dynamicSize)
        return fontResolver.resolve(resource: fontResource, with: parameters)
    }
    
}


extension View {
    
    public func fontResolver(_ resolver: FontResolver) -> some View {
        environment(\.fontResolver, resolver)
    }
    
}
