import SwiftUI


extension FontResource {
    
    public static func system(design: Font.Design) -> Self {
        .library(familyName: design.familyName)
    }
    
    public var design: Font.Design? {
        if case .library(let familyName) = self {
            return Font.Design.allCases.first(where: { $0.familyName == familyName })
        } else {
            return nil
        }
    }
    
    
}
