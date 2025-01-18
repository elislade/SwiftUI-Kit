import SwiftUI


// MARK: - Text Style


public extension Font.TextStyle {
    
    init(closestToStaticSize size: Double, in envrionment: EnvironmentValues = .init()) {
        
        let allValues = Self.allCases.map(\.baseSize)
        let distanceToValues: [(distance: Double, index: Int)] = allValues.indices.map{ i in
            (size - (allValues[i]), i)
        }
        
        let smallestToLargestDistances = distanceToValues.sorted(by: {
            pow($0.distance, 2) < pow($1.distance, 2)
        })
        
        let closestIndex = smallestToLargestDistances.first!.index
        self = Self.allCases[closestIndex]
    }
    
}


extension Font.TextStyle {
    
    var baseSize: CGFloat {
        switch self {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline: 17
        case .subheadline: 15
        case .body: 17
        case .callout: 16
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        case .extraLargeTitle: 36
        case .extraLargeTitle2: 28
        @unknown default: 16
        }
    }
    
}


extension DynamicTypeSize {
    
    var fontScale: CGFloat {
        switch self {
        case .xSmall: 0.8
        case .small: 0.9
        case .medium: 1
        case .large: 1.1
        case .xLarge: 1.2
        case .xxLarge: 1.3
        case .xxxLarge: 1.4
        case .accessibility1: 1.5
        case .accessibility2: 1.6
        case .accessibility3: 1.7
        case .accessibility4: 1.8
        case .accessibility5: 1.9
        @unknown default: 1
        }
    }
    
}


// MARK: - Width


@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Font.Width: @retroactive CustomStringConvertible {
    
    public var description: String {
        if self == .compressed {
            return "Compressed"
        } else if self == .condensed {
            return "Condensed"
        } else if self == .standard {
            return "Standard"
        } else if self == .expanded {
            return "Expanded"
        } else {
            return "\(value)"
        }
    }
    
    public var staticDefinedClosest: Self {
        let allValues: [Self] = [.compressed, .condensed, .standard, .expanded]
        let distanceToValues: [(distance: Double, index: Int)] = allValues.indices.map{ i in
            (value - allValues[i].value, i)
        }
        
        let smallestToLargestDistances = distanceToValues.sorted(by: {
            pow($0.distance, 2) < pow($1.distance, 2)
        })
        
        let closestIndex = smallestToLargestDistances.first!.index
        return allValues[closestIndex]
    }
    
}


// MARK: - Weight


public extension Font.Weight {
    
    /// Value in relation to the -1 to +1 scale as defined in ``FontParameters``.
    var value: Double {
        let all = Self.allCases
        let placeOfReference = Self.medium.codableValue
        
        func ratio(of value: Int, in count: Int) -> Double {
            Double(value) / Double(count - 1)
        }
        
        if codableValue < placeOfReference {
            let weights = Array(all[0...placeOfReference])
            let index = weights.firstIndex(of: self)!
            return -1 + ratio(of: index, in: weights.count)
        } else if codableValue > placeOfReference {
            let weights = Array(all[placeOfReference..<all.count])
            let index = weights.firstIndex(of: self)!
            return ratio(of: index, in: weights.count)
        } else {
            return 0
        }
    }
    
    /// Value in relation to the -1 to +1 scale as defined in ``FontParameters``.
    init(closestToValue value: Double) {
        let allValues = Self.allCases.map(\.value)
        let distanceToValues: [(distance: Double, index: Int)] = allValues.indices.map{ i in
            (value - (allValues[i]), i)
        }
        
        let smallestToLargestDistances = distanceToValues.sorted(by: {
            pow($0.distance, 2) < pow($1.distance, 2)
        })
        
        let closestIndex = smallestToLargestDistances.first!.index
        self = Self.allCases[closestIndex]
    }
    
    
}


extension Font.Weight : @retroactive CustomStringConvertible {
    
    public var description: String {
        if self == .black {
            "Black"
        } else if self == .heavy {
            "Heavy"
        } else if self == .bold {
            "Bold"
        } else if self == .semibold {
            "Semibold"
        } else if self == .medium {
            "Medium"
        } else if self == .regular {
            "Regular"
        } else if self == .light {
            "Light"
        } else if self == .thin {
            "Thin"
        } else if self == .ultraLight {
            "Ultra Light"
        } else {
            "Unknown"
        }
    }
    
}


// MARK: - Design


public extension Font.Design {
    
    var familyName: String {
        #if os(macOS)
        let osSpecifier: String = "NS"
        #else
        let osSpecifier: String = "UI"
        #endif

        switch self {
        case .default: return ".SF \(osSpecifier)"
        case .serif: return ".New York"
        case .rounded: return ".SF \(osSpecifier) Rounded"
        case .monospaced: return ".SF \(osSpecifier) Mono"
        @unknown default: return ".SF \(osSpecifier)"
        }
    }
    
}
