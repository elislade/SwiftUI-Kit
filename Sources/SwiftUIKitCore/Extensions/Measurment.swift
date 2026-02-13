import Foundation


public func formatFrequency(_ hertz: Int, compact: Bool = true) -> (value: String, postfix: String) {
    let attributedString = Measurement(
        value: Double(hertz),
        unit: UnitFrequency.hertz
    ).convertedToNearestWhole.formatted(.measurement(width: compact ? .narrow : .wide, usage: .asProvided).attributed)
    
    var value: [String] = []
    for run in attributedString.runs {
        let sub = attributedString.characters[run.range]
        if !sub.allSatisfy(\.isWhitespace) {
            value.append(String(sub))
        }
    }
    
    return (value[0], value[1])
}

extension Measurement where UnitType == UnitFrequency {
    
    public var convertedToNearestWhole: Self {
        let divisions: [UnitType] = [.nanohertz, .microhertz, .millihertz, .hertz, .kilohertz, .megahertz, .gigahertz, .terahertz]
        var index: Int = 0

        while true {
            let converted = converted(to: divisions[index])
            
            if converted.value.rounded() >= 1000 && divisions.indices.contains(index + 1) {
                index += 1
            } else {
                return Self(value: converted.value.rounded(), unit: converted.unit)
            }
        }
    }
    
}


public struct MeasurementParsing<U: Unit> : ParseStrategy {
    
    let formatStyle: FloatingPointFormatStyle<Double>?
    let unit: U
    
    public func parse(_ value: String) throws -> Measurement<U> {
        if let formatStyle {
            let value = try formatStyle.parseStrategy.parse(value)
            return Measurement(value: value, unit: unit)
        }
        
        // basic fallback parsing if a parser is nil
        let digitString = value
            // map european seperator for decimal
            .replacingOccurrences(of: ",", with: ".")
            .filter({ $0.isNumber || $0 == "." })
                                                                                
        if let value = Double(digitString) {
            return Measurement(value: value, unit: unit)
        } else {
            throw Error.unableToParseNumberFromInput
        }
    }
    
    enum Error: Swift.Error {
        case unableToParseNumberFromInput
    }
    
}


public struct Format<Base, Parsing> : ParseableFormatStyle where
    Base: FormatStyle,
    Parsing: ParseStrategy,
    Base.FormatOutput == Parsing.ParseInput,
    Base.FormatInput == Parsing.ParseOutput
{
    
    let base: Base
    public let parseStrategy: Parsing
    
    public func format(_ value: Base.FormatInput) -> Base.FormatOutput {
        base.format(value)
    }
    
}


extension MeasurementParsing : Decodable {
    
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.formatStyle = try container.decode(FloatingPointFormatStyle<Double>?.self)
        let coder = NSCoder()
        let data = try container.decode(Data.self)
        coder.encode(data)
        if let unit = U(coder: coder) {
            self.unit = unit
        }
        throw DecodingError.typeMismatch(U.self, .init(codingPath: [], debugDescription: ""))
    }
    
}

extension MeasurementParsing : Encodable {
    
    public func encode(to encoder: any Encoder) throws {
        var dataContainer = encoder.unkeyedContainer()
        try dataContainer.encode(formatStyle)
        let coder = NSCoder()
        unit.encode(with: coder)
        if let data = coder.decodeData() {
            try dataContainer.encode(data)
        }
    }
    
}

extension Measurement.FormatStyle {
    
    public func parseable(as unit: UnitType) -> Format<Self, MeasurementParsing<UnitType>> {
        Format(
            base: self,
            parseStrategy: MeasurementParsing<UnitType>(
                formatStyle: numberFormatStyle ?? .increment(0.1),
                unit: unit
            )
        )
    }
    
}


extension FormatStyle {
    
    public static func parse<U: Unit>(
        _ unit: U,
        format: FloatingPointFormatStyle<Double> = .increment(0.1)
    ) -> Self where Self == Format<Measurement<U>.FormatStyle, MeasurementParsing<U>> {
        Measurement<U>.FormatStyle.measurement(
            width: .narrow,
            numberFormatStyle: format
        ).parseable(as: unit)
    }
    
}
