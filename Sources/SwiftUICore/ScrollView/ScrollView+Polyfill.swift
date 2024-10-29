import SwiftUI


public extension View {
    
    @ViewBuilder func scrollClipDisabledPolyfill(_ disabled: Bool = true) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollClipDisabled(disabled)
        } else {
            self
        }
    }

    @ViewBuilder func scrollPositionPolyfill<V: Hashable>(id: Binding<V?>, anchor: UnitPoint? = nil) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollPosition(id: id, anchor: anchor)
        } else {
            /// Polyfills to just writing and has no reading capabilities
            /// It's recommeded to use on appear of each view in scroll to read the currently scrolled view.
            ScrollViewReader { proxy in
                self.onChangePolyfill(of: id.wrappedValue, initial: true){
                    if let animation = id.transaction.animation {
                        withAnimation(animation) {
                            proxy.scrollTo(id.wrappedValue, anchor: anchor)
                        }
                    } else {
                        proxy.scrollTo(id.wrappedValue, anchor: anchor)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func scrollTargetLayoutPolyfill(isEnabled: Bool = true) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollTargetLayout(isEnabled: isEnabled)
        } else {
            self
        }
    }
    
}
