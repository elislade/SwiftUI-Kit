import SwiftUI


extension FontParameters {
    
    public nonisolated subscript(weight: Font.Weight) -> Self {
        copy(replacing: \.weight, with: weight.value)
    }
    
    public nonisolated subscript(style: Font.TextStyle) -> Self {
        copy(replacing: \.size, with: style.baseSize)
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public nonisolated subscript(width: Font.Width) -> Self {
        copy(replacing: \.width, with: width.value)
    }
    
}


extension Font.Weight : Sendable {}


extension Font.Design: @retroactive CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .default: "Default"
        case .serif: "Serif"
        case .rounded: "Rounded"
        case .monospaced: "Monospaced"
        @unknown default: "Unknown"
        }
    }
    
}
