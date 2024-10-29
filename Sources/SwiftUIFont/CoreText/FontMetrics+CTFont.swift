
#if canImport(CoreText)

import CoreText

public extension FontMetrics {
    
    init(_ font: CTFont) {
        self.size = CTFontGetSize(font)
        self.ascent = CTFontGetAscent(font)
        self.descent = CTFontGetDescent(font)
        self.unitsPerEm = Int(CTFontGetUnitsPerEm(font))
        self.leading = CTFontGetLeading(font)
        self.capHeight = CTFontGetCapHeight(font)
        self.xHeight = CTFontGetXHeight(font)
        self.slantAngle = CTFontGetSlantAngle(font)
        self.underlineThickness = CTFontGetUnderlineThickness(font)
        self.underlinePosition = CTFontGetUnderlinePosition(font)
        self.numberOfGlyphs = CTFontGetGlyphCount(font)
    }
    
}

#endif
