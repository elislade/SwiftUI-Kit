import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation
import SwiftUIMenu

struct BackButton: View {
    
    @Environment(\.navViewBreadcrumbs) private var breadcrumbs
    @Environment(\.navViewDismissAction) private var dismissTo
    @Environment(\.dismissPresentation) private var dismissPresentation
    @State private var presented: [NavViewTitle]?
    
    var body: some View {
        Button{ dismissPresentation() } label: {
            Label { Text("Go Back") } icon: {
                Image(systemName: "arrow.left")
                    .layoutDirectionMirror()
            }
            .contentShape(Rectangle())
            //.simultaneousLongPress { presented = breadcrumbs }
            .gesture(
                LongPressGesture().onEnded{ _ in presented = breadcrumbs },
                including: breadcrumbs.isEmpty ? .subviews : .all
            )
        }
        .opacity(presented != nil ? 0 : 1)
        .scaleEffect(presented != nil ? 0.1 : 1)
        .animation(.bouncy, value: presented != nil)
        .keyboardShortcut(.cancelAction)
        .labelStyle(.iconOnly)
        .anchorPresentation(
            value: $presented,
            type: .explicit(source: .topLeading, destination: .topLeading)
        ){ crumbs in
            MenuContainer{
                ForEach(crumbs.reversed(), id:\.ownerID){ item in
                    Button{
                        dismissTo(item.ownerID)
                        presented = nil
                    } label: {
                        item.view.overlay {
                            Color.clear.contentShape(ContainerRelativeShape())
                        }
                    }
                    .actionTriggerBehaviour(.immediate)
                    .buttonStyle(.menu(dismissOnTrigger: false))
                }
            }
            .presentationBackdrop(.changedPassthrough)
            .transition(
                .asymmetric(
                    insertion: .scale(y: 0.1, anchor: .init(x: 0.1, y: 0.1)).animation(.navMenu)
                    + .scale(x: 0.2, anchor: .init(x: 0.1, y: 0.1)).animation(.navMenu.delay(0.1)),
                    removal: .scale(y: 0.1, anchor: .init(x: 0.1, y: 0.1)).animation(.navMenu.delay(0.1))
                    + .scale(x: 0.2, anchor: .init(x: 0.1, y: 0.1)).animation(.navMenu),
                )
                + .opacity.animation(.linear)
                + .blur(radius: 10).animation(.linear)
            )
        }
    }
    
}

extension Animation {
    
    static var navMenu: Animation {
        .bouncy(extraBounce: 0.15).speed(1.4)
    }
    
}

extension EnvironmentValues {
    
    @Entry var navViewDismissAction: (UniqueID) -> Void = { _ in }
    
}
