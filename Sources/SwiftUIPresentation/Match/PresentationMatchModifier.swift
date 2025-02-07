import SwiftUI


struct PresentationMatchModifier<MatchID: Hashable, Content: View>: View {
    
    @Environment(\.isBeingPresentedOn) private var isPresentedOn
    @State private var hide = false
    @State private var id = UUID()
    
    let matchID: MatchID
    let content: Content
    
    var body: some View {
        content
            .opacity(hide ? 0 : 1)
            .overlay {
                Color.clear
                    .anchorPreference(key: PresentationMatchKey.self, value: .bounds){
                        [.init(
                            id: id,
                            matchID: matchID,
                            isDestination: !isPresentedOn,
                            anchor: $0,
                            view: { AnyView(content) },
                            visibility: { visible in
                                DispatchQueue.main.async{
                                    hide = !visible
                                }
                            }
                        )]
                    }
            }
    }
    
}
