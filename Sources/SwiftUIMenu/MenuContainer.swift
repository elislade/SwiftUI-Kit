import SwiftUI
import SwiftUIKitCore


public struct MenuContainer<Content: View>: View {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.dismissPresentation) private var dismissPresentation
    @Environment(\.isInMenu) private var isInMenu
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    @Environment(\.isBeingPresented) private var isBeingPresented
    @Environment(\.presentationDepth) private var presentationDepth

    //@Environment(\.menuOrder) private var menuOrder
    
    @State private var callSelectedOnDissappear: Bool = false
    @State private var buttons: [MenuButtonValue] = []
    @State private var simulatedGesture: InteractionEvent?
    @State private var selectedIndex: Int?
    @State private var triggerTask: DispatchWorkItem?
    @State private var dwellTimer: Timer?
    
    private let selectionIndexBinding: Binding<Int?>?
    private let content: Content
    
    public init(
        selectionIndex: Binding<Int?>? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.selectionIndexBinding = selectionIndex
        self.content = content()
    }
    
    private var width: Double {
        360 - (200 * interactionGranularity)
    }
    
    private var defaultInsets: EdgeInsets {
#if os(iOS)
    .init(top: 8, leading: 16, bottom: 8, trailing: 16)
#else
    .init(top: 4, leading: 8, bottom: 4, trailing: 8)
#endif
    }
    
    
    public var body: some View {
        VStack(spacing: 0){ content }
            .equalInsetContext(defaultInsets: defaultInsets)
            //.disabled(isBeingPresentedOn)
            .opacity(1 - (Double(presentationDepth) / 3))
            .symbolRenderingMode(.hierarchical)
            .environment(\.isInMenu, true)
            .menuLabeledStyle()
            .toggleStyle(MenuToggleStyle())
            .buttonStyle(MenuButtonStyle())
            .labelStyle(MenuLabelStyle())
            .sensoryFeedbackPolyfill(value: selectedIndex)
            .onPreferenceChange(MenuButtonPreferenceKey.self){ _buttons.wrappedValue = $0 }
            .onChangePolyfill(of: selectionIndexBinding?.wrappedValue, initial: true){ _, new in
                selectedIndex = new
            }
            .windowDrag{ points in
                if let new = points.last {
                    selectedIndex = buttons.firstIndex(where: { $0.globalRect.contains(new) })
                } else {
                    self.selectedIndex = nil
                }
            } changed: { points in
                if let new = points.last {
                    selectedIndex = buttons.firstIndex(where: { $0.globalRect.contains(new) })
                } else {
                    self.selectedIndex = nil
                }
            } ended: { points in
                if let selectedIndex, buttons.indices.contains(selectedIndex) {
                    if buttons[selectedIndex].dismissOnAction {
                        if buttons[selectedIndex].actionBehaviour == .immediate {
                            buttons[selectedIndex].action()
                            callSelectedOnDissappear = false
                            self.selectedIndex = nil
                        } else {
                            callSelectedOnDissappear = true
                        }
                        
                        dismissPresentation()
                    } else {
                        callSelectedOnDissappear = true
                        buttons[selectedIndex].action()
                        self.selectedIndex = nil
                    }
                }
            }
            .windowHover{ point in
                selectedIndex = buttons.firstIndex(where: { $0.globalRect.contains(point) })
            }
            .onDisappear{
                if let selectedIndex, buttons.indices.contains(selectedIndex), callSelectedOnDissappear {
                    buttons[selectedIndex].action()
                    self.selectedIndex = nil
                }
            }
            .onChangePolyfill(of: selectedIndex, initial: true){
                for idx in buttons.indices {
                    buttons[idx].active(idx == selectedIndex)
                }
                
                dwellTimer?.invalidate()
                
                if let selectedIndex, buttons.indices.contains(selectedIndex), let dwell = buttons[selectedIndex].dwellDuration {
                    dwellTimer = .scheduledTimer(withTimeInterval: dwell, repeats: false){ _ in
                        DispatchQueue.main.async{
                            buttons[selectedIndex].action()
                            self.selectedIndex = nil
                        }
                    }
                }
            }
            .menuStyleTreatment(disabled: false)
            .frame(width: width)
    }
    
}


struct MenuTreatmentModifier : ViewModifier {
    
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.isBeingPresented) private var isBeingPresented
    @Environment(\.menuBackground) private var menuBackground
    
    private var radius: Double {
        30 - (25 * interactionGranularity)
    }
    
    func body(content: Content) -> some View {
        content.background {
            if let menuBackground {
                menuBackground
            } else {
                Rectangle()
                    .fill(.regularMaterial)
           }
        }
        .overlay{
            RoundedRectangle(cornerRadius: isBeingPresented ? radius : 0)
                .strokeBorder(lineWidth: 0.5)
                .opacity(isBeingPresented ? 0.4 : 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: isBeingPresented ? radius : 0))
        .shadow(color: .black.opacity(isBeingPresented ? 0.2 : 0), radius: 10, y: 5)
    }
    
}


extension View {
    
    @ViewBuilder func menuStyleTreatment(disabled: Bool = false) -> some View {
        if disabled {
            self
        } else {
            modifier(MenuTreatmentModifier())
        }
    }
    
}
