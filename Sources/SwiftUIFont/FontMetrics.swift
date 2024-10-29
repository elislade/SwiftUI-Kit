
public struct FontMetrics : Hashable, Codable, Sendable {
    
    public let size: Double
    public let ascent: Double
    public let descent: Double
    public let unitsPerEm: Int
    public let leading: Double
    public let capHeight: Double
    public let xHeight: Double
    public let slantAngle: Double
    public let underlineThickness: Double
    public let underlinePosition: Double
    public let numberOfGlyphs: Int
    
    
    public init(size: Double, ascent: Double, descent: Double, unitsPerEm: Int, leading: Double, capHeight: Double, xHeight: Double, slantAngle: Double, underlineThickness: Double, underlinePosition: Double, numberOfGlyphs: Int) {
        self.size = size
        self.ascent = ascent
        self.descent = descent
        self.unitsPerEm = unitsPerEm
        self.leading = leading
        self.capHeight = capHeight
        self.xHeight = xHeight
        self.slantAngle = slantAngle
        self.underlineThickness = underlineThickness
        self.underlinePosition = underlinePosition
        self.numberOfGlyphs = numberOfGlyphs
    }
    
    
    public static let empty = FontMetrics(size: 0, ascent: 0, descent: 0, unitsPerEm: 0, leading: 0, capHeight: 0, xHeight: 0, slantAngle: 0, underlineThickness: 0, underlinePosition: 0, numberOfGlyphs: 0)
    
}
