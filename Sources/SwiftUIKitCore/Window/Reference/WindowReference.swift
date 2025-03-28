#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public typealias OSWindow = NSWindow
#elseif os(iOS) || os(visionOS) || os(tvOS)
public typealias OSWindow = UIWindow
#else
public typealias OSWindow = Never
#endif


import SwiftUI


public extension View {
    
    #if !os(watchOS)
    
    func windowReference(closure: @escaping (OSWindow) -> Void) -> some View {
        modifier(WindowReferenceModifier(closure: closure))
    }
    
    #else
    
    func windowReference(closure: @escaping (OSWindow) -> Void) -> Self {
        self
    }
    
    #endif
    
}

#if !os(watchOS)

struct WindowReferenceModifier: ViewModifier {
    let closure: (OSWindow) -> Void
    
    func body(content: Content) -> some View {
        content.background {
            WindowReferenceRepresentation(reference: closure)
                .opacity(0)
                .allowsHitTesting(false)
        }
    }
    
}

#endif
