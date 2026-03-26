import SwiftUI

public struct GlassEffectContainerIfAvailable<Content: View>: View {
    
    let content: @MainActor () -> Content
    
    nonisolated public init(@ViewBuilder content: @MainActor @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        #if os(visionOS)
        content()
        #else
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            GlassEffectContainer(spacing: nil, content: content)
        } else {
            content()
        }
        #endif
    }
    
}


extension View {
    
    #if os(visionOS)
    
    nonisolated public func glassEffectIfAvailable(
        tint: Color? = nil,
        interactive: Bool = false,
        in shape: some Shape = Capsule(),
        other: (Self) -> some View
    ) -> some View {
        other(self)
    }
    
    #else
    
    @ViewBuilder nonisolated public func glassEffectIfAvailable(
        tint: Color? = nil,
        interactive: Bool = false,
        in shape: some Shape = Capsule(),
        other: (Self) -> some View
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            glassEffect(.regular.tint(tint).interactive(interactive), in: shape)
        } else {
            other(self)
        }
    }
    
    #endif
    
}
