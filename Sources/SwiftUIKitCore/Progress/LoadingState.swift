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
            self = .progress(max(min(value, 1), 0))
        } else {
            self = .indefinite
        }
    }
    
    public var fractionComplete: Double? {
        switch self {
        case .progress(let double): max(min(double, 1), 0)
        case .indefinite: nil
        }
    }
    
}
