import Foundation

public struct FontInfo: Hashable, Codable, Sendable {
    
    public let supportedLanguageCodes: [String]
    public var supportedLanguages: [String] {
        guard !supportedLanguageCodes.isEmpty else { return [] }
        let loc = CFLocaleCopyCurrent()//CFLocaleGetSystem()
        return supportedLanguageCodes.compactMap{
            let l = CFLocaleCopyDisplayNameForPropertyValue(loc, .languageCode, $0 as CFString)
            return l as String?
        }
    }
    
    
    public let supportedCharacters: CharacterSet

    public let familyName: String
    public let subFamilyName: String
    public let styleName: String
    
    /// - Note: This name is often not unique and should not be assumed to be truly unique.
    public let uniqueName: String
    
    public let fullName: String
    
    public let postScriptName: String
    public let postScriptCID: String
    
    public let trademark: String
    public let description: String
    public let version: String
    public let manufacturer: String
    
    public let designer: String
    public let designerURL: URL?
    
    public let copyright: String
    public let license: String
    public let licenseURL: URL?
    
    public let vendorURL: URL?
    public let sampleText: String
    
    
    public init(
        supportedLanguageCodes: [String] = [],
        supportedCharacters: CharacterSet = [],
        familyName: String = "",
        subFamilyName: String = "",
        styleName: String = "",
        uniqueName: String = "",
        fullName: String = "",
        postScriptName: String = "",
        postScriptCID: String = "",
        trademark: String = "",
        description: String = "",
        version: String = "",
        manufacturer: String = "",
        designer: String = "",
        designerURL: URL? = nil,
        copyright: String = "",
        license: String = "",
        licenseURL: URL? = nil,
        vendorURL: URL? = nil,
        sampleText: String = ""
    ) {
        self.supportedLanguageCodes = supportedLanguageCodes
        self.supportedCharacters = supportedCharacters
        self.familyName = familyName
        self.subFamilyName = subFamilyName
        self.styleName = styleName
        self.uniqueName = uniqueName
        self.fullName = fullName
        self.postScriptName = postScriptName
        self.postScriptCID = postScriptCID
        self.trademark = trademark
        self.description = description
        self.version = version
        self.manufacturer = manufacturer
        self.designer = designer
        self.designerURL = designerURL
        self.copyright = copyright
        self.license = license
        self.licenseURL = licenseURL
        self.vendorURL = vendorURL
        self.sampleText = sampleText
    }
    
    
}
