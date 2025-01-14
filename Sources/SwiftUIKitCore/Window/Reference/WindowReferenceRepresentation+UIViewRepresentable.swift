import SwiftUI


#if canImport(UIKit)

extension WindowReferenceRepresentation: UIViewRepresentable {
    
    func makeUIView(context: Context) -> WindowReaderView {
        let view = WindowReaderView()
        view.closure = reference
        return view
    }
    
    func updateUIView(_ uiView: WindowReaderView, context: Context) {
        uiView.closure = reference
    }
    
}


final class WindowReaderView: UIView {
    
    var closure: (UIWindow) -> Void = { _ in }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if let newWindow {
            closure(newWindow)
        }
    }
    
}

#endif
