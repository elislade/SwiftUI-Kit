import SwiftUI


public enum FontResource : Hashable, Codable {
    
    case library(familyName: String)
    case custom(url: URL)
    
    public static func system(design: Font.Design) -> Self {
        .library(familyName: design.familyName)
    }
    
    public var familyName: String? {
        if case .library(let familyName) = self {
            return familyName
        } else {
            return nil
        }
    }
    
    public var url: URL? {
        if case .custom(let url) = self {
            return url
        } else {
            return nil
        }
    }
    
    public var design: Font.Design? {
        if case .library(let familyName) = self {
            return Font.Design.allCases.first(where: { $0.familyName == familyName })
        } else {
            return nil
        }
    }
    
    public var isValid: Bool {
        switch self {
        case .library(let familyName):
            if familyName.first == "." {
                return Font.Design.allCases.map(\.familyName).contains(familyName)
            } else {
                return AvailableFont.fontFamilies.contains(familyName)
            }
        case .custom(let url):
            //TODO: Do more sophisticated URL checking
            return FileManager.default.fileExists(atPath: url.absoluteString)
        }
    }
    
    
    public func resolve(with params: FontParameters, in environment: EnvironmentValues = .init()) -> ResolvedFont {
        #if canImport(UIKit)
        let content = UIContentSizeCategory(environment.sizeCategory)
        let trait = UITraitCollection(preferredContentSizeCategory: content)
        let dynamicSize = UIFontMetrics.default.scaledValue(for: params.size, compatibleWith: trait)
        #else
        let dynamicSize = params.size
        #endif

        let parameters = params.copy(replacing: \.size, with: dynamicSize)
        
        var hasher = Hasher()
        self.hash(into: &hasher)
        parameters.hash(into: &hasher)
        let key = hasher.finalize()
        
        if let cached = FontCache.cache[key] {
            return cached
        } else {
            let resolver = FontFactory.shared.makeResolver()
            let resolved = resolver.resolve(resource: self, with: parameters)
            FontCache.cache[key] = resolved
            return resolved
        }
    }
    
}


extension FontResource: CustomStringConvertible {
    
    public var description: String {
        design?.description ?? familyName ?? url?.absoluteString ?? "Unknown"
    }
    
}

struct FontResourceKey: EnvironmentKey {
    
    static var defaultValue: FontResource = .system(design: .default)
    
}


public extension EnvironmentValues {
    
    var fontResource: FontResource {
        get { self[FontResourceKey.self] }
        set { self[FontResourceKey.self] = newValue }
    }
    
}


extension Font.Design: @retroactive CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .default: "Default"
        case .serif: "Serif"
        case .rounded: "Rounded"
        case .monospaced: "Monospaced"
        @unknown default: "Unknown"
        }
    }
    
}
