import SwiftUI
import Darwin

public enum FontResource : Hashable, Codable, Sendable {
    
    case library(familyName: String)
    case custom(url: FontURL)
    
    public nonisolated var familyName: String? {
        if case .library(let familyName) = self {
            return familyName
        } else {
            return nil
        }
    }
    
    public nonisolated var url: FontURL? {
        if case .custom(let url) = self {
            return url
        } else {
            return nil
        }
    }
    
    public nonisolated var isValid: Bool {
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
    
}


extension FontResource: CustomStringConvertible {
    
    public nonisolated var description: String {
        design?.description ?? familyName ?? url?.absoluteString ?? "Unknown"
    }
    
}
