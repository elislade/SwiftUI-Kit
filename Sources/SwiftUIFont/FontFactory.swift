import Foundation
import SwiftUI


public struct FontFactory {
    
    /// Override this shared property to replace the default  ``FontResolver`` with a custom one.
    //public static var shared: FontFactoryComformable = Self.swiftUI
    @MainActor public static var shared: FontFactoryComformable = Self.default
    
}


struct CTFontFactory : FontFactoryComformable {
    
    init(){}
    
    func makeResolver() -> FontResolver {
        CTFontResolver()
    }
    
}

struct SwiftUIFontFactory : FontFactoryComformable {
    
    init(){}
    
    func makeResolver() -> FontResolver {
        SwiftUIFontResolver()
    }
    
}

final class FontCache {
    
    @MainActor static var cache: [Int : ResolvedFont] = [:]
    
}

public extension FontFactory {
    
    static var `default`: FontFactoryComformable { CTFontFactory() }
    static var swiftUI: FontFactoryComformable { SwiftUIFontFactory() }
    
}

public protocol FontFactoryComformable {
    
    func makeResolver() -> FontResolver
    
}


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
