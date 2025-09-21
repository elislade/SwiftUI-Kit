import SwiftUI


public extension View {
    
    nonisolated func fontWidthPolyfill(_ value: CGFloat = 0) -> some View {
        fontWidth(.init(value))
    }
    
    @ViewBuilder nonisolated func fontDesignPolyfill(_ design: Font.Design?) -> some View {
        if #available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, *) {
            self.fontDesign(design)
        } else {
            self
        }
    }
    
    nonisolated func trackingPolyfill(_ tracking: CGFloat) -> some View {
        self.tracking(tracking)
    }
    
    nonisolated func baselineOffsetPolyfill(_ baselineOffset: CGFloat) -> some View {
        self.baselineOffset(baselineOffset)
    }
    
    nonisolated func kerningPolyfill(_ kerning: CGFloat) -> some View {
        self.kerning(kerning)
    }
    
}
