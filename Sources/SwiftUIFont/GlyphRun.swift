import SwiftUI
import SwiftUIKitCore
@preconcurrency import CoreText

#if canImport(UIKit)
public typealias OSFont = UIFont
#elseif canImport(AppKit)
public typealias OSFont = NSFont
#else
public typealias OSFont = Never
#endif


public final class GlyphRun: @unchecked Sendable {
    
    public let text: [Character]
    public let font: CTFont
    public let glyphs: [CGGlyph]
    public let axix: Axis = .horizontal
    
    public nonisolated convenience init(_ text: String, font: CTFont) {
        self.init(text.map({ $0 }), font: font)
    }
    
    public nonisolated init(_ text: [Character], font: CTFont) {
        self.text = text
        self.font = font
        
        var charRefs: [UInt16] = text.compactMap{ $0.utf16.first }
        var glyphs = Array(repeating: CGGlyph(), count: charRefs.count)
        _ = CTFontGetGlyphsForCharacters(font, &charRefs, &glyphs, charRefs.count)
        self.glyphs = glyphs
    }
    
    subscript(index: Int) -> Character {
        text[index]
    }
    
    public private(set) lazy var verticalTranslations: [CGSize] = {
        guard !glyphs.isEmpty else { return [] }
        var result = Array(repeating: CGSize(), count: glyphs.count)
        CTFontGetVerticalTranslationsForGlyphs(font, glyphs, &result, glyphs.count)
        return result
    }()
    
    public private(set) lazy var advances: [CGSize] = {
        guard !glyphs.isEmpty else { return [] }
        var result = Array(repeating: CGSize(), count: glyphs.count)
        CTFontGetAdvancesForGlyphs(font, .horizontal, glyphs, &result, glyphs.count)
        return result
    }()
    
    public private(set) lazy var bounds: [CGRect] = {
        guard !glyphs.isEmpty else { return [] }
        var result: [CGRect] = Array(repeating: .zero, count: glyphs.count)
        CTFontGetBoundingRectsForGlyphs(font, .horizontal, glyphs, &result, glyphs.count)
        return result
    }()
    
    public private(set) lazy var opticalBounds: [CGRect] = {
        guard !glyphs.isEmpty else { return [] }
        var result: [CGRect] = Array(repeating: .zero, count: glyphs.count)
        CTFontGetOpticalBoundsForGlyphs(font, glyphs, &result, glyphs.count, 0)
        return result
    }()
    
    public private(set) lazy var runRect: CGRect = {
        guard !glyphs.isEmpty else { return .zero }
        return CTFontGetBoundingRectsForGlyphs(font, .default, glyphs, nil, glyphs.count)
    }()
    
    public private(set) lazy var totalSize: CGSize = {
        guard !glyphs.isEmpty else { return .zero }
        return CGSize(
            width: advances.map(\.width).reduce(0, +),
            height: opticalBounds.map(\.height).sorted().first!
        )
    }()
    
    public func path(withScale scale: Double = 1) -> Path? {
        guard !glyphs.isEmpty else { return nil }
        return Path { ctx in
            var total: Double = 0
            for (offset, glyph) in glyphs.enumerated() {
                var transform = CGAffineTransform.identity
                    .scaledBy(x: scale, y: -scale)
                    .translatedBy(x: total, y: verticalTranslations[offset].height)
                
                total += advances[offset].width
                
                if var path = CTFontCreatePathForGlyph(font, glyph, &transform){
                    path = path.normalized(using: .winding)
                    ctx.addPath(Path(path))
                }
            }
        }
    }
    
}


extension GlyphRun: PathProvider {
    
    public func path(in rect: CGRect) -> Path {
        guard rect != .zero else { return .init() }
        let widthRatio = rect.width / totalSize.width
        let heightRatio = rect.height / totalSize.height
        let scale = min(widthRatio, heightRatio)
        return path(withScale: scale) ?? .init()
    }
    
}


extension GlyphRun : InsettableShape {
    
    public nonisolated func inset(by amount: CGFloat) -> some InsettableShape {
        self
    }
    
    public nonisolated func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        let size = proposal.replacingUnspecifiedDimensions()
        let scale = scaleOfFitting(size, in: totalSize)
        return CGSize(
            width: totalSize.width * scale,
            height: totalSize.height * scale
        )
    }
    
}
