import SwiftUI
import SwiftUIKitCore

public struct PresentationBackground: View {
    
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
                Button(action: dismiss){
                    presentationBG
                        .contentShape(Rectangle())
                        .accessibilityLabel(Text("Dismiss Presentation"))
                }
                .buttonStyle(PresentationBGButtonStyle())
                .keyboardShortcut(.escape, modifiers: [])
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged{ _ in
                            if bgInteraction == .touchChangeDismiss {
                                dismiss()
                            }
                        }
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
