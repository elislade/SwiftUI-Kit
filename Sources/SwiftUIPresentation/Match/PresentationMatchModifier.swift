import SwiftUI


struct PresentationMatchModifier<MatchID: Hashable, Copy: View>: ViewModifier {
    
    @Environment(\.isSnapshot) private var isSnapshot
    @Environment(\.isInPresentationMatch) private var isInPresentationMatch
    @Environment(\.isPresentationMatchEnabled) private var isEnabled
    @Environment(\.presentationMatchCaptureMode) private var captureMode
    
    @State private var hide = false
    @State private var id = UUID()
    @State private var view: AnyView?
    @State private var snapshotUpdatedSignal: Bool = false
    
    let matchID: MatchID
    let active: Bool
    let copy: @MainActor () -> Copy
    
    init(id: MatchID, active: Bool = true, @ViewBuilder copy: @MainActor @escaping () -> Copy){
        self.matchID = id
        self.copy = copy
        self.active = active
    }
    
    private func makeElement(_ anchor: Anchor<CGRect>) -> MatchGroup.Element {
        .init(
            anchor: anchor,
            view: { AnyView(copy()) },
            isVisible: $hide.inverse
        )
    }
    
    private func makeElement(_ anchor: Anchor<CGRect>, view: AnyView) -> MatchGroup.Element {
        .init(
            id: UUID().hashValue,
            anchor: anchor,
            view: { view },
            isVisible: $hide.inverse
        )
    }

    func body(content: Content) -> some View {
        switch captureMode {
        case .newInstance:
            content
                .opacity(hide ? 0 : 1)
                .background{
                    if active && isEnabled {
                        Color.clear.anchorPreference(key: PresentationMatchKey.self, value: .bounds){ anchor in
                            [.init(
                                id: id,
                                matchID: matchID,
                                source: makeElement(anchor)
                            )]
                        }
                    }
                }
        case .snapshot:
            content
                .viewSnapshot(for: hide, initial: true){
                    if active && isEnabled {
                        view = $0
                        snapshotUpdatedSignal.toggle()
                    }
                }
                .opacity(hide ? 0 : 1)
                .background{
                    ZStack {
                        // wait for snapshot
                        if let view {
                            Color.clear.anchorPreference(key: PresentationMatchKey.self, value: .bounds){ anchor in
                                [.init(
                                    id: id,
                                    matchID: matchID,
                                    source: makeElement(anchor, view: view)
                                )]
                            }
                        }
                    }
                    .id(snapshotUpdatedSignal)
                }
        }
    }
    
}
