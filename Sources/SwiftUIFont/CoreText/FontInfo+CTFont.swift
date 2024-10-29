import Foundation


#if canImport(CoreText)

import CoreText

public extension FontInfo {
    
    init(_ font: CTFont) {
        self.supportedLanguageCodes = CTFontCopySupportedLanguages(font) as! [String]
        self.supportedCharacters = CTFontCopyCharacterSet(font) as CharacterSet
        self.familyName = (CTFontCopyName(font, kCTFontFamilyNameKey) as String?) ?? ""
        self.subFamilyName = (CTFontCopyName(font, kCTFontSubFamilyNameKey) as String?) ?? ""
        self.styleName = (CTFontCopyName(font, kCTFontStyleNameKey) as String?) ?? ""
        self.uniqueName = (CTFontCopyName(font, kCTFontUniqueNameKey) as String?) ?? ""
        self.fullName = (CTFontCopyName(font, kCTFontFullNameKey) as String?) ?? ""
        self.postScriptName = (CTFontCopyName(font, kCTFontPostScriptNameKey) as String?) ?? ""
        self.postScriptCID = (CTFontCopyName(font, kCTFontPostScriptCIDNameKey) as String?) ?? ""
        self.trademark = (CTFontCopyName(font, kCTFontTrademarkNameKey) as String?) ?? ""
        self.description = (CTFontCopyName(font, kCTFontDescriptionNameKey) as String?) ?? ""
        self.version = (CTFontCopyName(font, kCTFontVersionNameKey) as String?) ?? ""
        self.manufacturer = (CTFontCopyName(font, kCTFontManufacturerNameKey) as String?) ?? ""
        self.designer = (CTFontCopyName(font, kCTFontDesignerNameKey) as String?) ?? ""
        self.copyright = (CTFontCopyName(font, kCTFontCopyrightNameKey) as String?) ?? ""
        self.license = (CTFontCopyName(font, kCTFontLicenseNameKey) as String?) ?? ""
        self.sampleText = (CTFontCopyName(font, kCTFontSampleTextNameKey) as String?) ?? ""
        
        if let urlString = CTFontCopyName(font, kCTFontDesignerURLNameKey) {
            self.designerURL = URL(string: urlString as String)
        } else {
            self.designerURL = nil
        }

        if let urlString = CTFontCopyName(font, kCTFontLicenseURLNameKey) {
            self.licenseURL = URL(string: urlString as String)
        } else {
            self.licenseURL = nil
        }
        
        if let urlString = CTFontCopyName(font, kCTFontVendorURLNameKey) {
            self.vendorURL = URL(string: urlString as String)
        } else {
            self.vendorURL = nil
        }
    }
    
}

#endif
