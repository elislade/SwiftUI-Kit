import SwiftUI

/// Replicates new iOS 17+ OnChange behaviour for older OS's

struct OnChangeOldNewPolyfill<Value: Equatable>: ViewModifier {
    
    @State private var oldValue: Value
    
    let value: Value
    let initial: Bool
    let callback: ((Value, Value) -> Void)
    
    init(value: Value, initial: Bool, callback: @escaping (Value, Value) -> Void) {
        self._oldValue = State(initialValue: value)
        self.value = value
        self.initial = initial
        self.callback = callback
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: value){ deprecatedValue in
                callback(oldValue, deprecatedValue)
                oldValue = deprecatedValue
            }
            .onAppear {
                if initial {
                    callback(oldValue, value)
                }
            }
    }
 
}

struct OnChangePolyfill<Value: Equatable>: ViewModifier, Sendable {

    @State private var lastState: Value?
    
    let value: Value
    let initial: Bool
    let callback: () -> Void
    
    init(value: Value, initial: Bool, callback: @escaping () -> Void) {
        self.value = value
        self.initial = initial
        self.callback = callback
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: value){ lastState = $0 }
            .onChange(of: lastState){ s in
                callback()
            }
            .onAppear {
                if initial {
                    lastState = value
                }
            }
    }
 
}


public extension View {
    
    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// You can use `onChangePolyfill` to trigger a side effect as the result of a
    /// value changing, such as an `Environment` key or a `Binding`.
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task.
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value. The old and new observed values are
    /// passed into the closure. In the following code example, `PlayerView`
    /// passes both the old and new values to the model.
    ///
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .onChangePolyfill(of: playState) { oldState, newState in
    ///                 model.playStateDidChange(from: oldState, to: newState)
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - initial: Whether the action should be run when this view initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///   - oldValue: The old value that failed the comparison check (or the
    ///     initial value when requested).
    ///   - newValue: The new value that failed the comparison check.
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    @ViewBuilder func onChangePolyfill<V: Equatable>(of value: V, initial: Bool = false, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            onChange(of: value, initial: initial, action)
        } else {
            modifier(OnChangeOldNewPolyfill(value: value, initial: initial, callback: action))
        }
    }
    
    
    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// You can use `onChangePolyfill` to trigger a side effect as the result of a
    /// value changing, such as an `Environment` key or a `Binding`.
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task.
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value. In the following code example,
    /// `PlayerView` calls into its model when `playState` changes model.
    ///
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .onChangePolyfill(of: playState) {
    ///                 model.playStateDidChange(state: playState)
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - initial: Whether the action should be run when this view initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///   
    /// - Returns: A view that fires an action when the specified value changes.
    @ViewBuilder func onChangePolyfill<V: Equatable>(of value: V, initial: Bool = false, _ action: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            onChange(of: value, initial: initial, action)
        } else {
            modifier(OnChangePolyfill(
                value: value,
                initial: initial,
                callback: action
            ))
        }
    }
    
    
}
