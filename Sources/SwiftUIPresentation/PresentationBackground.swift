import SwiftUI
import SwiftUIKitCore

public struct PresentationBackground: View {
    
    //@Environment(\.lastCoordinatedGestureLocation) private var lastLocation
    
    private let bgView: AnyView?
    private let bgInteraction: PresentationBackgroundInteraction?
    private let dismiss: () -> Void
    
    public init(
        bgView: AnyView? = nil,
        bgInteraction: PresentationBackgroundInteraction? = nil,
        dismiss: @escaping () -> Void
    ) {
        self.bgView = bgView
        self.bgInteraction = bgInteraction
        self.dismiss = dismiss
    }
    
    private var useBGInteraction: Bool {
        if let bgInteraction {
            bgInteraction != .disabled
        } else {
            true
        }
    }
    
    @ViewBuilder private var presentationBG: some View {
        if let bgView {
            bgView
        } else {
            Color.black.opacity(0.4)
        }
    }
    
    public var body: some View {
        ZStack {
            if useBGInteraction {
                //PresBGGestureRepresentable {
                    Button(action: dismiss){
                        presentationBG
                            .contentShape(Rectangle())
                            .accessibilityLabel(Text("Dismiss Presentation"))
                            //.allowsHitTesting(false)
                    }
                    //.allowsHitTesting(false)
                    .buttonStyle(PresentationBGButtonStyle())
                    .keyboardShortcut(.escape, modifiers: [])
                //}
//                .onChangePolyfill(of: lastLocation != nil){ old, new in
//                    if bgInteraction == .touchChangeDismiss, new {
//                        dismiss()
//                    }
//                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ _ in
                            if bgInteraction == .touchChangeDismiss {
                                dismiss()
                            }
                        })
                        .onEnded({ _ in
                            
                        })
                )
               
            } else {
                presentationBG.allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }
    
}


struct PresentationBGButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
    
}


//struct PresBGGestureRepresentable<Content: View>: UIViewControllerRepresentable {
//    
//    
//    @ViewBuilder let content: Content
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        let c = Host(rootView: content)
//        c.view.backgroundColor = .clear
//        c.view.isUserInteractionEnabled = false
//        return c
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        
//    }
//    
////    func makeUIView(context: Context) -> UIView {
////        CustomView()
////    }
////    
////    func updateUIView(_ uiView: UIView, context: Context) {
////        
////    }
//    
//}
//
//class CustomView: UIView {
//    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        print("Hit Test", point)
//        return nil
//    }
//    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        print("Hit Test Inside", point)
//        return false
//    }
//    
//}
//
//class Host<Content: View>: UIHostingController<Content> {
//    
//    //override var canBecomeFirstResponder: Bool { false }
//    
//}
