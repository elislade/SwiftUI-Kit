import SwiftUI


public extension EnvironmentValues {
    
    /// A suggestion for views that may want to use as their primary layout method instead of system LTR and RTL layouts.
    var layoutDirectionSuggestion: LayoutDirectionSuggestion {
        get { self[LayoutDirectionSuggestionKey.self] }
        set { self[LayoutDirectionSuggestionKey.self] = newValue }
    }
    
}


struct LayoutDirectionSuggestionKey: EnvironmentKey {
    
    static var defaultValue: LayoutDirectionSuggestion = .useSystemDefault
    
}


/// A suggestion for views that may want to use as their primary layout method instead of system LTR and RTL layouts.
public enum LayoutDirectionSuggestion: UInt8, CaseIterable {
    
    /// A suggestion to use system LayoutDirection with LTR or RTL.
    case useSystemDefault
    
    /// A suggestion to use Top to Bottom as primary layout.
    case useTopToBottom
    
    /// A suggestion to use Bottom to Top as primary layout.
    case useBottomToTop
    
    /// A suggestion to use vertical as primary layout.
    public var useVertical: Bool { self != .useSystemDefault }
}


public extension View {
    
    /// Disables ``LayoutDirectionSuggestion`` for this view.
    /// - Parameter disabled: A Bool indicating whether its disabled or not.
    /// - Returns: A view that can disable ``LayoutDirectionSuggestion``
    @inlinable func disableLayoutSuggestion(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.layoutDirectionSuggestion) { value in
            if disabled {
                value = .useSystemDefault
            }
        }
    }
    
    /// LayoutDirectionSuggestions are just a suggestion for views to utilize over the default LayoutDirection.  It does not mean every view will or should use this to layout, it's only a suggestion that some subview may use it for layout if desired. For example it can be used to tell Sliders to layout vertically if set but will **NOT** force an `HStack` to layout vertically or change the direction of a normal `VStack`.
    /// - Parameter suggestion: A ``LayoutDirectionSuggestion`` for this view.
    /// - Returns: A view with ``LayoutDirectionSuggestion`` set as an `EnvironmentValue.
    @inlinable func layoutDirectionSuggestion(_ suggestion: LayoutDirectionSuggestion) -> some View {
        environment(\.layoutDirectionSuggestion, suggestion)
    }
    
}
