import SwiftUI

public extension Font {
    
    subscript(weight: Font.Weight) -> Font {
        self.weight(weight)
    }
    
    subscript(leading: Font.Leading) -> Font {
        self.leading(leading)
    }
    
    subscript(width: Font.Width) -> Font {
        self.width(width)
    }
    
}
