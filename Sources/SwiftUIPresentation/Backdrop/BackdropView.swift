import SwiftUI
import SwiftUIKitCore


struct BackdropView: View {
    
    let preference: BackdropPreference?
    let dismiss: () -> Void
    
    private var useBGInteraction: Bool {
        guard let preference else { return true }
        return preference.interaction != .disabled
    }
    
    @ViewBuilder private var content: some View {
        if let view = preference?.view(){
            view
        } else {
            Color.black.opacity(0.4)
        }
    }
    
    var body: some View {
        ZStack {
            if useBGInteraction {
                Button(action: dismiss){
                    content
                        .contentShape(Rectangle())
                        .accessibilityLabel(Text("Dismiss Presentation"))
                }
                .buttonStyle(PresentationBGButtonStyle())
                .keyboardShortcut(SwiftUIKitCore.KeyEquivalent.escape, modifiers: [])
                #if !os(tvOS)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged{ _ in
                            if preference?.interaction == .touchChangeDismiss {
                                dismiss()
                            }
                        }
                )
                #endif
            } else {
                content.allowsHitTesting(false)
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
