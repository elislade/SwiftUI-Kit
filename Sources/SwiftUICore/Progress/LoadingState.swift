import Foundation


public enum LoadingState: Hashable, Sendable, Codable {
    
    /// Progress ranging from 0(start) to 1(end).
    case progress(Double)
    
    /// State with an unknown end progress
    case indefinite
    
    
    /// Initializes instance
    /// - Parameter value: An optional Double for the progress. If `nil` it will be `indefinite`.
    public init(_ value: Double?){
        if let value {
            self = .progress(value)
        } else {
            self = .indefinite
        }
    }
    
    public var fractionComplete: Double? {
        switch self {
        case .progress(let double): double
        case .indefinite: nil
        }
    }
    
}
