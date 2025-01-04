import Foundation


#if canImport(CoreText)

import CoreText

public extension FontInfo {
    
    /// Memberwise initializer
    /// - Parameter ctFont: A `CTFont` to use for info.
    init(_ ctFont: CTFont) {
        self.supportedLanguageCodes = CTFontCopySupportedLanguages(ctFont) as! [String]
        self.supportedCharacters = CTFontCopyCharacterSet(ctFont) as CharacterSet
        self.familyName = (CTFontCopyName(ctFont, kCTFontFamilyNameKey) as String?) ?? ""
        self.subFamilyName = (CTFontCopyName(ctFont, kCTFontSubFamilyNameKey) as String?) ?? ""
        self.styleName = (CTFontCopyName(ctFont, kCTFontStyleNameKey) as String?) ?? ""
        self.uniqueName = (CTFontCopyName(ctFont, kCTFontUniqueNameKey) as String?) ?? ""
        self.fullName = (CTFontCopyName(ctFont, kCTFontFullNameKey) as String?) ?? ""
        self.postScriptName = (CTFontCopyName(ctFont, kCTFontPostScriptNameKey) as String?) ?? ""
        self.postScriptCID = (CTFontCopyName(ctFont, kCTFontPostScriptCIDNameKey) as String?) ?? ""
        self.trademark = (CTFontCopyName(ctFont, kCTFontTrademarkNameKey) as String?) ?? ""
        self.description = (CTFontCopyName(ctFont, kCTFontDescriptionNameKey) as String?) ?? ""
        self.version = (CTFontCopyName(ctFont, kCTFontVersionNameKey) as String?) ?? ""
        self.manufacturer = (CTFontCopyName(ctFont, kCTFontManufacturerNameKey) as String?) ?? ""
        self.designer = (CTFontCopyName(ctFont, kCTFontDesignerNameKey) as String?) ?? ""
        self.copyright = (CTFontCopyName(ctFont, kCTFontCopyrightNameKey) as String?) ?? ""
        self.license = (CTFontCopyName(ctFont, kCTFontLicenseNameKey) as String?) ?? ""
        self.sampleText = (CTFontCopyName(ctFont, kCTFontSampleTextNameKey) as String?) ?? ""
        
        if let urlString = CTFontCopyName(ctFont, kCTFontDesignerURLNameKey) {
            self.designerURL = URL(string: urlString as String)
        } else {
            self.designerURL = nil
        }

        if let urlString = CTFontCopyName(ctFont, kCTFontLicenseURLNameKey) {
            self.licenseURL = URL(string: urlString as String)
        } else {
            self.licenseURL = nil
        }
        
        if let urlString = CTFontCopyName(ctFont, kCTFontVendorURLNameKey) {
            self.vendorURL = URL(string: urlString as String)
        } else {
            self.vendorURL = nil
        }
    }
    
}

#endif
