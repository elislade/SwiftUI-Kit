import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public typealias OSWindow = NSWindow
#elseif canImport(UIKit)
public typealias OSWindow = UIWindow
#else
public typealias OSWindow = Never
#endif


public extension View {
    
    func windowReference(closure: @escaping (OSWindow) -> Void) -> some View {
        modifier(WindowReferenceModifier(closure: closure))
    }
    
}


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
