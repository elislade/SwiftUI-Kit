import CoreText
import SwiftUI


//MARK: - Frame


public struct Frame : RandomAccessCollection, Equatable {
    
    private let lines: [CTLine]
    private let origins: [CGPoint]
    
    public let startIndex: Int
    public let endIndex: Int
    public let size: CGSize
    
    public init(string: String, font: CTFont, frame: Path) {
        let attributes = ["NSFont" as CFString : font]
        let attributedString = CFAttributedStringCreate(
            nil,
            string as CFString,
            attributes as CFDictionary
        )!
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let ctframe = CTFramesetterCreateFrame(framesetter, CFRange(), frame.cgPath, nil)
        let size = frame.boundingRect.size
        let suggestion = CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter, CFRange(), nil,
            CGSize(width: size.width, height: .greatestFiniteMagnitude),
            nil
        )
        self.init(ctframe, suggestedSize: suggestion)
    }
    
    init(_ frame: CTFrame, suggestedSize: CGSize? = nil) {
        let lines = CTFrameGetLines(frame) as! [CTLine]
        var origins: [CGPoint] = Array(repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(frame, CFRange(location: 0, length: lines.count), &origins)
        self.startIndex = 0
        self.lines = lines
        self.endIndex = lines.count
        self.origins = origins
        self.size = suggestedSize ?? .zero
    }
    
    public subscript(bounds: Range<Int>) -> Slice {
        Slice(slice: lines[bounds], origins: origins[bounds])
    }
    
    public subscript(position: Int) -> Line {
        Line(lines[position], origin: origins[position])
    }
    
    public var path: Path {
        Path { ctx in
            for i in indices {
                let origin = origins[i]
                ctx.addPath(self[i].path.offsetBy(dx: origin.x, dy: (origin.y * -1) + size.height))
            }
        }
    }
    
}

extension Frame {
    
    public struct Slice : RandomAccessCollection, Equatable {
        
        private let lines: ArraySlice<CTLine>
        private let origins: ArraySlice<CGPoint>
        
        public let startIndex: Int
        public let endIndex: Int
        
        init(
            slice: ArraySlice<CTLine>,
            origins: ArraySlice<CGPoint>
        ){
            self.lines = slice
            self.origins = origins
            self.startIndex = slice.startIndex
            self.endIndex = slice.endIndex
        }
        
        public subscript(bounds: Range<Int>) -> Slice {
            Slice(slice: lines[bounds], origins: origins)
        }
        
        public subscript(position: Int) -> Line {
            Line(lines[position], origin: origins[position])
        }
        
        public var path: Path {
            Path { ctx in
                for i in indices {
                    let origin = origins[i]
                    ctx.addPath(self[i].path.offsetBy(dx: origin.x, dy: origin.y))
                }
            }
        }
        
    }
    
}


//MARK: - Line


public struct Line : RandomAccessCollection, Equatable {
    
    private let runs: [CTRun]
    
    public let startIndex: Int
    public let endIndex: Int
    public let origin: CGPoint
    public let typographicBounds: TypographicBounds
    
    init(_ line: CTLine, origin: CGPoint) {
        self.startIndex = 0
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        self.endIndex = runs.count
        self.runs = runs
        self.origin = origin
        self.typographicBounds = .init(line)
    }
    
    public subscript(bounds: Range<Int>) -> Slice {
        Slice(slice: runs[bounds], origins: [])
    }
    
    public subscript(position: Int) -> Run {
        Run(runs[position])
    }
    
    public var path: Path {
        Path { ctx in
            for i in indices {
                ctx.addPath(self[i].path)
            }
        }
    }
    
}



extension Line {
    
    public struct TypographicBounds : Equatable {
        
        public let width: Double
        public let ascent: Double
        public let descent: Double
        public let leading: Double
        
        init(_ line: CTLine){
            var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
            self.width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            self.ascent = ascent
            self.descent = descent
            self.leading = leading
        }
        
    }
    
    public struct Slice : RandomAccessCollection, Equatable {
        
        private let runs: ArraySlice<CTRun>
        private let origins: ArraySlice<CGPoint>
        
        public let startIndex: Int
        public let endIndex: Int
        
        init(
            slice: ArraySlice<CTRun>,
            origins: ArraySlice<CGPoint>
        ){
            self.runs = slice
            self.origins = origins
            self.startIndex = slice.startIndex
            self.endIndex = slice.endIndex
        }
        
        public subscript(bounds: Range<Int>) -> Slice {
            Slice(slice: runs[bounds], origins: origins)
        }
        
        public subscript(position: Int) -> Run {
            Run(runs[position])
        }
        
        public var path: Path {
            Path { ctx in
                for i in indices {
                    ctx.addPath(self[i].path)
                }
            }
        }
        
    }
    
}


//MARK: - Run


public struct Run : RandomAccessCollection, Equatable {

    public static func == (lhs: Run, rhs: Run) -> Bool {
        lhs.startIndex == rhs.startIndex
        && lhs.endIndex == rhs.endIndex
        && lhs.glyphs == rhs.glyphs
        && lhs.positions == rhs.positions
    }
    
    public let startIndex: Int
    public let endIndex: Int

    private let glyphs: UnsafePointer<CGGlyph>
    private let positions: UnsafePointer<CGPoint>
    private let attributes: [String : Any]
    
    init(_ run: CTRun) {
        self.startIndex = 0
        self.endIndex = CTRunGetGlyphCount(run)
        self.glyphs = CTRunGetGlyphsPtr(run)!
        self.positions = CTRunGetPositionsPtr(run)!
        self.attributes = CTRunGetAttributes(run) as! [String : Any]
    }
    
    public subscript(bounds: Range<Int>) -> Slice {
        withUnsafePointer(to: attributes){ attributesPointer in
            Slice(
                bounds: bounds,
                glyphs: glyphs,
                positions: positions,
                attributes: attributesPointer
            )
        }
    }
    
    public subscript(position: Int) -> Element {
        Glyph(
            glyphs[position],
            font: attributes["NSFont"] as! CTFont
        )
    }
    
    public var path: Path {
        Path { ctx in
            for i in indices {
                let position = positions[i]
                ctx.addPath(self[i].path.offsetBy(dx: position.x, dy: position.y))
            }
        }
    }
    
}


extension Run {
    
    public struct Slice : RandomAccessCollection {
        
        public let startIndex: Int
        public let endIndex: Int
        
        private let glyphs: UnsafePointer<CGGlyph>
        private let positions: UnsafePointer<CGPoint>
        private let attributes: UnsafePointer<[String: Any]>
        
        init(
            bounds: Range<Int>,
            glyphs: UnsafePointer<CGGlyph>,
            positions: UnsafePointer<CGPoint>,
            attributes: UnsafePointer<[String: Any]>
        ){
            self.startIndex = bounds.lowerBound
            self.endIndex = bounds.upperBound
            self.glyphs = glyphs
            self.positions = positions
            self.attributes = attributes
        }
        
        public subscript(bounds: Range<Int>) -> Slice {
            Slice(
                bounds: bounds,
                glyphs: glyphs,
                positions: positions,
                attributes: attributes
            )
        }
        
        public subscript(position: Int) -> Glyph {
            Glyph(
                glyphs[position],
                font: attributes.pointee["NSFont"] as! CTFont
            )
        }
        
        public var path: Path {
            Path { ctx in
                for i in indices {
                    ctx.addPath(self[i].path)
                }
            }
        }
        
    }
    
}


//MARK: - Glyph


public struct Glyph : Equatable {
    
    let glyph: CGGlyph
    let font: CTFont
    let normalizeOffset: Bool
    
    public init(_ character: Character, font: CTFont){
        var glyphs: CGGlyph = 0
        var char: UInt16 = character.utf16.first ?? 0
        CTFontGetGlyphsForCharacters(font, &char, &glyphs, 1)
        self.init(glyphs, font: font, normalizeOffset: true)
    }
    
    init(_ glyph: CGGlyph, font: CTFont, normalizeOffset: Bool = false) {
        self.glyph = glyph
        self.font = font
        self.normalizeOffset = normalizeOffset
    }
    
    public var path: Path {
        let flipY = CGAffineTransform(scaleX: 1, y: -1)
        if let path = withUnsafePointer(to: flipY, { pointer in
            CTFontCreatePathForGlyph(font, glyph, pointer)
        }) {
            let normalizedY = normalizeOffset ? path.boundingBoxOfPath.minY : 0
            let normalizedX = normalizeOffset ? path.boundingBoxOfPath.minX : 0
            return Path(path.normalized(using: .winding))
                .offsetBy(dx: -normalizedX, dy: -normalizedY)
        } else {
            return Path{ _ in }
        }
    }
    
}
