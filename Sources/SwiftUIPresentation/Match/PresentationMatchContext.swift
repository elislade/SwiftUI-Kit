import SwiftUI


struct PresentationMatchContextModifier: ViewModifier {
    
    @State private var divertUpdatesUntilDoneDismissing: Bool = false
    @State private var divertedGroups: [(PresentationMatchElement, PresentationMatchElement)] = []
    @State private var groups: [(PresentationMatchElement, PresentationMatchElement)] = []
    @State private var activatedGroups: [(source: UUID, active: Bool)] = []
    
    private func restoreDivertedGroups() {
        groups = divertedGroups
        divertedGroups = []
        divertUpdatesUntilDoneDismissing = false
    }
    
    private func binding(for sourceID: UUID) -> Binding<Bool> {
        Binding(
            get: {
                activatedGroups.first(where: { $0.source == sourceID })!.active
            },
            set: {
                let idx = activatedGroups.firstIndex(where: { $0.source == sourceID })!
                activatedGroups[idx].active = $0
            }
        )
    }
    
    func body(content: Content) -> some View {
        content
            .onPresentationWillDismiss {
                if divertUpdatesUntilDoneDismissing {
                    restoreDivertedGroups()
                } else if !groups.isEmpty {
                    divertUpdatesUntilDoneDismissing = true
                }
            }
            .onPreferenceChange(PresentationMatchKey.self){ elements in
                //print("Matches",elements.map(\.matchID))
                var takenIndices: Set<Int> = []
                var groups: [(PresentationMatchElement, PresentationMatchElement)] = []
                
                for i in elements.indices {
                    let source = elements[i]
                    if takenIndices.contains(i) && source.isDestination { continue }
                    
                    if let otherIDX = elements.firstIndex(where: { $0.id != source.id && $0.matchID == source.matchID && $0.isDestination }) {
                        let destination = elements[otherIDX]
                        takenIndices.insert(otherIDX)
                        takenIndices.insert(i)
                        groups.append((source, destination))
                        if !_activatedGroups.wrappedValue.contains(where: { $0.source == source.id }){
                            _activatedGroups.wrappedValue.append((source.id, false))
                        }
                    }
                }
                
                if _divertUpdatesUntilDoneDismissing.wrappedValue {
                    _divertedGroups.wrappedValue = groups
                } else {
                    _groups.wrappedValue = groups
                }
                
//                print("Groups", _groups.wrappedValue)
//                print("Groups Diverted", _divertedGroups.wrappedValue)
            }
            .overlay {
                ForEach(groups, id: \.0.matchID) { group in
                    MatchView(
                        active: binding(for: group.0.id),
                        from: group.0,
                        to: group.1,
                        didReturnToSource: restoreDivertedGroups
                    )
                    .disableOnPresentationWillDismiss(group.0.matchID != groups.last?.0.matchID)
                }
            }
    }
    
    
    struct MatchView: View {
        
        @Binding var active: Bool
        let from: PresentationMatchElement
        let to: PresentationMatchElement
        let didReturnToSource: () -> Void
        
        @State private var workItems: [DispatchWorkItem] = []
        @State private var done = false
        
        var body: some View {
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    Color.clear
                    
                    let source = proxy[from.anchor]
                    let destination = proxy[to.anchor]
                    
                    from.view()
                        .allowsHitTesting(false)
                        .opacity(active ? 0 : 1)
                        .frame(width: source.width, height: source.height)
                        .scaleEffect(
                            CGSize(
                                width: active ? destination.width / source.width : 1,
                                height: active ? destination.height / source.height : 1
                            ),
                            anchor: .topLeading
                        )
                        .offset(active ? destination.origin : source.origin)
                        .onAppear {
                            guard active == false else {
                                done = true
                                return
                            }
                            
                            to.visibility(false)
                            from.visibility(false)
                            
                            active = true
                            
                            for item in workItems {
                                item.cancel()
                            }
                            
                            workItems = []
                            
                            let workItem = DispatchWorkItem {
                                to.visibility(true)
                                done = true
                            }
                            
                            workItems.append(workItem)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
                        }
//                        .onDisappear {
//                            from.visibility(true)
//                            to.visibility(true)
//                        }
                    
                    to.view()
                        .allowsHitTesting(false)
                        .opacity(active ? 1 : 0)
                        .frame(width: destination.width, height: destination.height)
                        .scaleEffect(
                            CGSize(
                                width: active ? 1 : source.width / destination.width,
                                height: active ? 1 : source.height / destination.height
                            ),
                            anchor: .topLeading
                        )
                        .offset(active ? destination.origin : source.origin)
                }
                
            }
            .animation(.interpolatingSpring.speed(1.4), value: active)
            .opacity(done ? 0 : 1)
            .onPresentationWillDismiss {
                guard active else { return }
     
                done = false
                active = false
                
                from.visibility(false)
                to.visibility(false)
                
                for item in workItems {
                    item.cancel()
                }
                
                workItems =  []
                
                let workItem = DispatchWorkItem {
                    from.visibility(true)
                    to.visibility(true)
                    didReturnToSource()
                }
                
                workItems.append(workItem)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
            }
        }
        
    }
}

