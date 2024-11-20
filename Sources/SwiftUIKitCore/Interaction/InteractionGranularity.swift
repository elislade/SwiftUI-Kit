import SwiftUI


struct InteractionGranularityKey: EnvironmentKey {
    
    #if os(macOS)
    static var defaultValue: Double { 1 }
    #elseif os(iOS)
    static var defaultValue: Double { 0.5 }
    #elseif os(tvOS)
    static var defaultValue: Double { 0 }
    #elseif os(visionOS)
    static var defaultValue: Double { 0.25 }
    #else
    static var defaultValue: Double { 1 }
    #endif
    
}


public extension EnvironmentValues {
    
    var interactionGranularity: Double {
        get { self[InteractionGranularityKey.self] }
        set { self[InteractionGranularityKey.self] = newValue }
    }
    
}


public extension View {
    
    /// Sets the interaction granularity
    /// - Parameter granularity: A `Double` from `0` to `1` where `0` is least granular and `1` is most.
    /// - Note: Input modalities have different interaction granularities, focused based inputs such as tv remotes are most coarse while the tip of a mouse cursor is least coarse. The point of this is to issolate interaction granularity from the specific OS as an OS may support multiple input modalities and the UI should adapt accordenly. An example would be iPadOS supporting pencil, mouse/trackpad, and direct-touch, all of these have their own granularity. Depending on the current main interaction type the views can adapt to adjust hit-area sizes and padding as an example.
    ///
    /// - Returns: A view.
    func interactionGranularity(_ granularity: Double) -> some View {
        environment(\.interactionGranularity, granularity.clamped(to: 0...1))
    }
    
}
