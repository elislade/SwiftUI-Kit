import SwiftUI


struct SubmenuLabel<L: View> : View {
    
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.isBeingPresented) private var isPresented
    @Environment(\.isBeingPresentedOn) private var isPresentedOn
    @Environment(\.dismissPresentation) private var dismiss
    
    @State private var leadingWidth: CGFloat = .menuLeadingSpacerSize
    
    var isStandalone = false
    var action: @MainActor () -> Void = {}
    @ViewBuilder let label: @MainActor () -> L
    
    private var isExpanded: Bool { !isStandalone && isPresented }

    var body: some View {
        Button{
            if isExpanded {
                dismiss()
            } else {
                action()
            }
        } label: {
            HStack(spacing: 0) {
                label()

                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .font(.body[.bold])
                    .scaleEffect(0.5)
                    .opacity(0.5)
                    .rotationEffect(isExpanded ? .degrees(90 * layoutDirection.scaleFactor) : .zero)
                    .layoutDirectionMirror()
                    .frame(width: 22)
            }
        }
        .buttonStyle(MenuButtonStyle(
            dismissWhenTriggered: false
        ))
        .animation(.smooth, value: isPresentedOn)
        .actionDwellDuration(0.8)
        .actionTriggerBehaviour(.immediate)
    }
    
}
