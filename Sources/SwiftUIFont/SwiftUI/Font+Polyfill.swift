import SwiftUI


public extension View {
    
    @ViewBuilder func fontWidthPolyfill(_ value: CGFloat = 0) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.fontWidth(.init(value))
        } else {
            self
        }
    }
    
    @ViewBuilder func fontDesignPolyfill(_ design: Font.Design?) -> some View {
        if #available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, *) {
            self.fontDesign(design)
        } else {
            self
        }
    }
    
    @ViewBuilder func trackingPolyfill(_ tracking: CGFloat) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.tracking(tracking)
        } else {
            self
        }
    }
    
    @ViewBuilder func baselineOffsetPolyfill(_ baselineOffset: CGFloat) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.baselineOffset(baselineOffset)
        } else {
            self
        }
    }
    
    @ViewBuilder func kerningPolyfill(_ kerning: CGFloat) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.kerning(kerning)
        } else {
            self
        }
    }
    
}
