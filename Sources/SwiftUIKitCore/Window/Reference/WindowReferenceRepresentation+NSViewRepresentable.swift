import SwiftUI


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

extension WindowReferenceRepresentation: NSViewRepresentable {
    
    func makeNSView(context: Context) -> WindowReaderView {
        let view = WindowReaderView()
        view.closure = reference
        return view
    }
    
    func updateNSView(_ nsView: WindowReaderView, context: Context) {
        nsView.closure = reference
    }
    
}


final class WindowReaderView: NSView {
    
    var closure: (NSWindow) -> Void = { _ in }
    
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if let newWindow {
            closure(newWindow)
        }
    }
    
}

#endif
