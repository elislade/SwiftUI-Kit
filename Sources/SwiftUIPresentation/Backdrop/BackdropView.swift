import SwiftUI
import SwiftUIKitCore


struct BackdropView: View {
    
    @Environment(\.dismissPresentation) private var dismissEnv
    @State private var changeCalled = false
    
    let preference: BackdropPreference?
    let dismiss: () -> Void
    
    var body: some View {
        Group {
            if let preference {
                ZStack {
                    preference.view()
                        .allowsHitTesting(false)
                    
                    if let interaction = preference.interaction {
                        if interaction.trigger == .changedPassthrough {
                            Color.clear
                                .accessibilityLabel(Text("Dismiss Presentation"))
                                .allowsHitTesting(false)
                                .preferredGesture(
                                    priority: .simultaneous,
                                    gesture: DragGesture(minimumDistance: 0).onChanged({ value in
                                        if !changeCalled {
                                            dismiss()
                                            changeCalled = true
                                        }
                                    })
                                )
                                .onDisappear{ changeCalled = false }
                        } else {
                            Color.clear
                                .contentShape(ContainerRelativeShape())
                                .gesture(DragGesture(minimumDistance: 0).onChanged{ _ in
                                    if
                                        (interaction.trigger == .changed
                                        || interaction.trigger == .changedPassthrough)
                                        && !changeCalled
                                    {
                                        changeCalled = true
                                        dismiss()
                                    }
                                }.onEnded{ _ in
                                    changeCalled = false
                                    if interaction.trigger == .ended {
                                        dismiss()
                                    }
                                })
                        }
                    }
                }
            } else {
                Button{ dismiss() } label: {
                    ContainerRelativeShape()
                        .fill(.black.opacity(0.4))
                        .accessibilityLabel(Text("Dismiss Presentation"))
                }
            }
        }
        .buttonStyle(BGButtonStyle())
        .keyboardShortcut(.cancelAction)
        .ignoresSafeArea()
    }
    
    
    struct BGButtonStyle: ButtonStyle {
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
        
    }
    
}
