
#if canImport(CoreText)

import CoreText

public extension FontMetrics {
    
    
    /// Memberwise initializer
    /// - Parameter ctFont: A `CTFont` to use for metrics.
    init(_ ctFont: CTFont) {
        self.size = CTFontGetSize(ctFont)
        self.ascent = CTFontGetAscent(ctFont)
        self.descent = CTFontGetDescent(ctFont)
        self.unitsPerEm = Int(CTFontGetUnitsPerEm(ctFont))
        self.leading = CTFontGetLeading(ctFont)
        self.capHeight = CTFontGetCapHeight(ctFont)
        self.xHeight = CTFontGetXHeight(ctFont)
        self.slantAngle = CTFontGetSlantAngle(ctFont)
        self.underlineThickness = CTFontGetUnderlineThickness(ctFont)
        self.underlinePosition = CTFontGetUnderlinePosition(ctFont)
        self.numberOfGlyphs = CTFontGetGlyphCount(ctFont)
    }
    
}

#endif
