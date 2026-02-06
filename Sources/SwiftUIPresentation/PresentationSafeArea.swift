import SwiftUI


struct PresentationSafeAreaKey: PreferenceKey {
    
    static var defaultValue: EdgeInsets? { nil }
    
    static func reduce(value: inout EdgeInsets?, nextValue: () -> EdgeInsets?) {
        let next = nextValue()
        
        if next != Self.defaultValue {
            value = next
        }
    }
    
}


extension View {
    
    nonisolated public func presentationSafeAreaContext(enabled: Bool = true) -> some View {
        modifier(PresentationSafeAreaModifier(enabled: enabled))
    }
    
    nonisolated func presentationSafeArea(_ insets: EdgeInsets?) -> some View {
        preference(key: PresentationSafeAreaKey.self, value: insets)
    }
    
    nonisolated func presentationSafeAreaDisabled(_ disabled: Bool = true) -> some View {
        preferenceKeyReset(PresentationSafeAreaKey.self, reset: disabled)
    }
    
    nonisolated func onPresentationSafeAreaChange(perform action: @escaping (EdgeInsets?) -> Void) -> some View {
        onPreferenceChange(PresentationSafeAreaKey.self, perform: action)
    }
    
}


struct PresentationSafeAreaModifier: ViewModifier {
    
    @State private var safeArea: EdgeInsets?
    let enabled: Bool
    
    func body(content: Content) -> some View {
        content
            .presentationSafeArea(enabled ? safeArea : nil)
            .onSafeAreaChange(.container){ insets in
                Task(priority: .low) { @MainActor in
                    safeArea = insets
                }
            }
    }
    
}


struct PresentationSourceKey: PreferenceKey {
    
    static var defaultValue: Anchor<CGRect>? { nil }
    
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        if let next = nextValue() {
            value = next
        }
    }
    
}


extension View {
    
    /// Defines a custom presentation source when it should match to a view other than the view handling presentation.
    nonisolated public func presentationSource(active: Bool = true) -> some View {
        anchorPreference(key: PresentationSourceKey.self, value: .bounds) {
            active ? $0 : nil
        }
    }
    
    nonisolated public func presentationSourceChange(perform action: @escaping (Anchor<CGRect>?) -> ()) -> some View {
        preferenceChangeConsumer(PresentationSourceKey.self, perform: action)
    }
    
}
