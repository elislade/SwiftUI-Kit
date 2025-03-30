import SwiftUI


// MARK: Design


extension Font.Design {
    
    public static var allCases: [Font.Design] {
        [.default, .serif, .rounded, .monospaced]
    }
    
    var codableValue: Int {
        switch self {
        case .default: return 0
        case .serif: return 1
        case .rounded: return 2
        case .monospaced: return 3
        @unknown default: return -1
        }
    }
    
}

extension Font.Design: @retroactive Identifiable {
    public var id: Int { codableValue }
}

extension Font.Design : @retroactive Encodable {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codableValue)
    }
    
}


extension Font.Design : @retroactive Decodable {
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        for item in Self.allCases {
            if item.codableValue == value {
                self = item
                return
            }
        }
        self = .default
    }
    
}


// MARK: TextStyle


extension Font.TextStyle {
    
    var codableValue: Int {
        switch self {
        case .largeTitle: return 0
        case .title: return 1
        case .title2: return 2
        case .title3: return 3
        case .headline: return 4
        case .subheadline: return 5
        case .body: return 6
        case .callout: return 7
        case .footnote: return 8
        case .caption: return 9
        case .caption2: return 10
        case .extraLargeTitle: return 11
        case .extraLargeTitle2: return 12
        @unknown default: return -1
        }
    }
    
}

extension Font.TextStyle: @retroactive Identifiable {
    public var id: Int { codableValue }
}

extension Font.TextStyle : @retroactive Encodable {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codableValue)
    }
    
}

extension Font.TextStyle : @retroactive Decodable {
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        for item in Self.allCases {
            if item.codableValue == value {
                self = item
                return
            }
        }
        self = .body
    }
    
}


// MARK: Weight


extension Font.Weight {
    
    public static var allCases: [Font.Weight] {
        [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black]
    }
    
    var codableValue: Int {
        switch self {
        case .ultraLight: 0
        case .thin: 1
        case .light: 2
        case .regular: 3
        case .medium: 4
        case .semibold: 5
        case .bold: 6
        case .heavy: 7
        case .black: 8
        default: 3
        }
    }
}

extension Font.Weight : @retroactive Encodable {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codableValue)
    }
    
}

extension Font.Weight : @retroactive Decodable {
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        for item in Self.allCases {
            if item.codableValue == value {
                self = item
                return
            }
        }
        
        self = .regular
    }
    
}


// MARK: Leading


extension Font.Leading: @retroactive CaseIterable {
    
    public static var allCases: [Font.Leading] { [.tight, .standard, .loose] }
    
    var codableValue: Int {
        switch self {
        case .standard: 0
        case .tight: 1
        case .loose: 2
        @unknown default: 0
        }
    }
    
}


extension Font.Leading: @retroactive Encodable {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codableValue)
    }
    
}


extension Font.Leading: @retroactive Decodable {
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        for item in Self.allCases {
            if item.codableValue == value {
                self = item
                return
            }
        }
        
        self = .standard
    }
    
}
