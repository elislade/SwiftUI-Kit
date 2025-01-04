
#if canImport(CoreText)

import CoreText
import SwiftUI

public final class CTFontResolver : FontResolver  {
    
    
    public init() { }
    
    
    private func symbolic(for trait: FontTrait) -> CTFontSymbolicTraits? {
        switch trait {
        case .italic: .traitItalic
        case .smallCaps: nil
        case .smallCapsUppercase: nil
        case .smallCapsLowercase: nil
        case .monospaced: .monoSpaceTrait
        case .monospacedDigit: .monoSpaceTrait
        }
    }

    private func resolveTraits(for parameters: FontParameters) -> CFDictionary {
        [
            kCTFontWeightTrait: parameters.weight,
            kCTFontWidthTrait : parameters.width,
            kCTFontSlantTrait : parameters.slant//,
            //kCTFontSymbolicTrait : parameters.traits.compactMap{ symbolic(for: $0) }
        ] as CFDictionary
    }
    
    private func resolveAttributes(resource: FontResource, for parameters: FontParameters) -> CFDictionary {
        [
            kCTFontSizeAttribute : parameters.size,
            kCTFontNameAttribute : resource.familyName ?? "",
           // kCTFontURLAttribute : asset.url?.absoluteString ?? "",
            kCTFontTraitsAttribute : resolveTraits(for: parameters),
            kCTFontOrientationAttribute : CTFontOrientation.vertical
        ] as CFDictionary
    }
    
    public func resolve(resource: FontResource, with parameters: FontParameters) -> ResolvedFont {
        let attributes = resolveAttributes(resource: resource, for: parameters)
        let descriptor = CTFontDescriptorCreateWithAttributes(attributes)
        let fontBeforeApplyingAttributesAndSymbolicTraits = CTFontCreateWithFontDescriptor(descriptor, parameters.size, .none)
        var transform = parameters.transform
        
        let opaqueFont = CTFontCreateCopyWithAttributes(
            fontBeforeApplyingAttributesAndSymbolicTraits,
            0,
            &transform,
            descriptor
        )

        var font = Font(opaqueFont)
        
        if parameters.traits.contains(.monospacedDigit){
            font = font[.monospacedDigit]
        }
        
        return ResolvedFont(
            parameters: parameters,
            opaqueFont: font,
            info: .init(opaqueFont),
            metrics: .init(opaqueFont)
        )
    }
    
}


public enum AvailableFont {
    
    public static let postScripts: [String] = CTFontManagerCopyAvailablePostScriptNames() as! [String]
    public static let fontFamilies: [String] = CTFontManagerCopyAvailableFontFamilyNames() as! [String]
    
}

public extension Collection where Element == String {
    
    static var availablePostScriptNames: [String] { AvailableFont.postScripts }
    static var availableFontFamilyNames: [String] { AvailableFont.fontFamilies }
    
}


#endif
