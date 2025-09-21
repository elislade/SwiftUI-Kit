import Foundation
import SwiftUI


public struct SwiftUIFontResolver: FontResolver {
    
    public init(){}
    
    public func resolve(resource: FontResource, with parameters: FontParameters) -> ResolvedFont {
        var font: Font = .system(.body)
        
        if let design = resource.design {
            font = .system(size: parameters.size, design: design)
        } else if let name = resource.familyName {
            font = .custom(name, size: parameters.size)
        }
        
        font = font.traits(parameters.traits)
        
        if parameters.slant > 0 {
            font = font.italic()
        }
        
        font = font.width(.init(parameters.width))
        
        return ResolvedFont(
            parameters: parameters,
            opaqueFont: font.weight(.init(closestToValue: parameters.weight)),
            info: .init(), // Info is unavailable to SwiftUI resolver.
            metrics: .zero // Metrics is unavailable to SwiftUI resolver.
        )
    }
    
}

extension EnvironmentValues {
    
    @Entry var fontResolver: FontResolver = SwiftUIFontResolver()
    
    public var resolvedFont: ResolvedFont {
        #if canImport(UIKit) && !os(watchOS)
        let content = UIContentSizeCategory(sizeCategory)
        let trait = UITraitCollection(preferredContentSizeCategory: content)
        let dynamicSize = UIFontMetrics.default.scaledValue(for: fontParameters.size, compatibleWith: trait)
        #else
        let dynamicSize = fontParameters.size * dynamicTypeSize.fontScale
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
