import SwiftUI

struct FontResourceKey: EnvironmentKey {
    
    static var defaultValue: FontResource { .system(design: .default) }
    
}


public extension EnvironmentValues {
    
    var fontResource: FontResource {
        get { self[FontResourceKey.self] }
        set { self[FontResourceKey.self] = newValue }
    }
    
}




struct FontParametersKey: EnvironmentKey {
    
    static var defaultValue: FontParameters { .identity }
    
}



public extension EnvironmentValues {
    
    var fontParameters: FontParameters {
        get { self[FontParametersKey.self] }
        set { self[FontParametersKey.self] = newValue }
    }
    
    var fontResourceFont: Font {
        resolvedFont.opaqueFont
    }
    
}
