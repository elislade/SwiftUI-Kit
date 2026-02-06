import SwiftUI
@preconcurrency import CoreText

public struct TextShape<FrameShape: Shape> : Hashable, Shape {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.string == rhs.string
        && lhs.font == rhs.font
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
        hasher.combine(font)
    }
    
    let string: String
    let font: CTFont
    let shape: FrameShape
    
    public init(string: String, font: CTFont, inside shape: FrameShape = Rectangle()) {
        self.string = string
        self.font = font
        self.shape = shape
    }
    
    nonisolated public func path(in rect: CGRect) -> Path {
        Frame(
            string: string,
            font: font,
            frame: shape.scale(y: -1).path(in: rect)
        ).path
    }
    
    nonisolated public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        let size = shape.scale(y: -1).sizeThatFits(proposal)
        return Frame(
            string: string,
            font: font,
            frame: shape.scale(y: -1).path(in: CGRect(origin: .zero, size: size))
        ).size
    }
    
}
