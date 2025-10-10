import SwiftUI

struct InteractionHoverGroupModifier {
    
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn: Bool
    
    @State private var id = UUID()
    @State private var previousID: UUID?
    @State private var elements: [InteractionHoverElement] = []
    
    @GestureState private var isActive = false
    
    var priority: InteractionPriority = .normal
    var delay: Duration = .zero
    var action: (InteractionHoverGroupEvent) -> Void = { _ in }
    
}


extension InteractionHoverGroupModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        //let previousID = previousID
        content
            .coordinateSpace(name: id)
            .environment(\.interactionGroupCoordinateSpace, .named(id))
            .onPreferenceChange(InteractionHoverElementPreference.self){ elements = $0 }
            .resetPreference(InteractionHoverElementPreference.self)
            .onChangePolyfill(of: isActive){
                if !isActive {
                    action(.init(date: Date(), phase: .ended))
                }
            }
            .gesture(
                priority.gesturePriority ?? .none,
                LongPressGesture(
                    minimumDuration: delay.seconds,
                    maximumDistance: 3
                )
                .sequenced(
                    before: DragGesture(minimumDistance: 0)
                        .onChanged{ gesture in
                            
                            if !isActive {
                                action(.init(date: Date(), phase: .started))
                            }
                            
                            let location = gesture.location
                            
                            if let index = elements.firstIndex(where: { $0.coordinateSpaceBounds.contains(location) }) {
                                let id = elements[index].id
                                
                                if previousID != id {
                                    if let previousIndex = elements.firstIndex(where: { $0.id == previousID }) {
                                        elements[previousIndex](.left)
                                        action(.init(date: Date(), phase: .exited))
                                    }
                                    
                                    elements[index](.entered)
                                    action(.init(date: Date(), phase: .entered))
                                    self.previousID = id
                                }
                             
                            } else if let previousIndex = elements.firstIndex(where: { $0.id == previousID }) {
                                elements[previousIndex](.left)
                                action(.init(date: Date(), phase: .exited))
                                self.previousID = nil
                            }
                        }
                        .updating($isActive){ _, state, _ in
                            if !state {
                                print("Start")
                            }
                            state = true
                        }
                        .onEnded{ gesture in
                            let location = gesture.location
                            
                            if let index = elements.firstIndex(where: { $0.coordinateSpaceBounds.contains(location) }) {
//                                if
//                                    id != previousID,
//                                    let previousIndex = elements.firstIndex(where: { $0.id == previousID })
//                                {
//                                    elements[previousIndex](.left)
//                                    action(.init(date: Date(), phase: .exited))
//                                }
                                
                                elements[index](.ended)
                                self.previousID = nil
                            }
                        }
                )
            )
    }
    
    
}
