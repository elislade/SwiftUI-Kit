import SwiftUI

public extension Font {
    
    subscript(weight: Font.Weight) -> Font {
        self.weight(weight)
    }
    
    subscript(leading: Font.Leading) -> Font {
        self.leading(leading)
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    subscript(width: Font.Width) -> Font {
        self.width(width)
    }
    
}
