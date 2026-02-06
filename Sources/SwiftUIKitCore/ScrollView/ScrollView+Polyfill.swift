import SwiftUI


extension View {
    
    nonisolated public func scrollClipDisabledPolyfill(_ disabled: Bool = true) -> some View {
        scrollClipDisabledIfAvailable(disabled)
    }
    
    @ViewBuilder nonisolated public func scrollClipDisabledIfAvailable(_ disabled: Bool = true) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollClipDisabled(disabled)
        } else {
            self
        }
    }

    @ViewBuilder nonisolated public func scrollPositionPolyfill<V: Hashable>(id: Binding<V?>, anchor: UnitPoint? = nil) -> some View {
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
    
    @ViewBuilder nonisolated public func scrollTargetPagingIfAvailable() -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollTargetBehavior(.paging)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated public func scrollTargetViewAlignedIfAvailable() -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated public func scrollTargetLayoutIfAvailable(isEnabled: Bool = true) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollTargetLayout(isEnabled: isEnabled)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated public func contentMarginsIfAvailable(_ edges: Edge.Set = .all, _ length: Double) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            contentMargins(edges, length, for: .scrollIndicators)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated public func contentMarginsIfAvailable(_ length: Double) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            contentMargins(length, for: .scrollIndicators)
        } else {
            self
        }
    }
    
}
