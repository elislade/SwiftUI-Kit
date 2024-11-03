import SwiftUI
import Combine

public extension Timer {
    
    /// A shorthand for creating a repeating Timer Publisher using the main `RunLoop` using the `default` mode.
    /// - Parameter duration: The time in seconds that the timer should wait between emitting.
    /// - Returns: A TimerPublisher.
    @inlinable static func every(_ duration: TimeInterval) -> Timer.TimerPublisher {
        publish(every: duration, on: .main, in: .default)
    }
    
}


public extension Timer.TimerPublisher {
    
    /// A shorthand for creating a repeating Timer Publisher using the main `RunLoop` using the `default` mode.
    /// - Parameter duration: The time in seconds that the timer should wait between emitting.
    /// - Returns: A TimerPublisher.
    @inlinable static func every(_ duration: TimeInterval) -> Timer.TimerPublisher {
        Timer.publish(every: duration, on: .main, in: .default)
    }
    
}
