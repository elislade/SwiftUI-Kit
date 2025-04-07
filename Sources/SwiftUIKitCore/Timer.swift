import Foundation
import Combine

public extension Timer {
    
    /// A shorthand for creating a repeating Timer Publisher using the main `RunLoop` using the `default` mode.
    /// - Parameter duration: The time in seconds that the timer should wait between emitting.
    /// - Returns: A TimerPublisher.
    static func every(_ duration: TimeInterval, on runLoop: RunLoop = .main, in mode: RunLoop.Mode = .default) -> Publishers.Autoconnect<Timer.TimerPublisher> {
        publish(every: duration, on: runLoop, in: mode).autoconnect()
    }
    
}


public extension Timer.TimerPublisher {
    
    /// A shorthand for creating a repeating Timer Publisher using the main `RunLoop` using the `default` mode.
    /// - Parameter duration: The time in seconds that the timer should wait between emitting.
    /// - Returns: A TimerPublisher.
    static func every(_ duration: TimeInterval, on runLoop: RunLoop = .main, in mode: RunLoop.Mode = .default) -> Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: duration, on: runLoop, in: mode).autoconnect()
    }
    
}
