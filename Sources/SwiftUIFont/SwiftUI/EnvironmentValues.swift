import SwiftUI

public extension EnvironmentValues {
    
    @Entry var fontResource: FontResource = .system(design: .default)
    @Entry var fontParameters: FontParameters = .identity
    
    var fontResourceFont: Font {
        resolvedFont.opaqueFont
    }
    
}
