import SwiftUI


struct PresentationMatchModifier<MatchID: Hashable, Copy: View>: ViewModifier {
    
    @Environment(\.presentationMatchCaptureMode) private var captureMode
    
    @State private var hide = false
    @State private var id = UUID()
    @State private var view: AnyView?
    @State private var snapshotUpdatedSignal: Bool = false
    
    let matchID: MatchID
    let copy: @MainActor () -> Copy
    
    init(id: MatchID, @ViewBuilder copy: @MainActor @escaping () -> Copy){
        self.matchID = id
        self.copy = copy
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
                    Color.clear.anchorPreference(key: PresentationMatchKey.self, value: .bounds){ anchor in
                        [.init(
                            id: id,
                            matchID: matchID,
                            source: makeElement(anchor)
                        )]
                    }
                }
        case .snapshot:
            content
                .viewSnapshot(for: hide, initial: true){
                    view = $0
                    snapshotUpdatedSignal.toggle()
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
