import SwiftUI

struct InteractionHoverGestureGroup {
    
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn: Bool
    @Environment(\.interactionHoverEnabled) private var enabled
    
    @State private var id = UUID()
    @State private var previousID: UUID?
    @State private var elements: [InteractionHoverElement] = []
    
    @GestureState private var isActive = false
    
    let priority: GesturePriority
    let delay: Duration
    let action: (InteractionHoverGroupEvent) -> Void
    
}


extension InteractionHoverGestureGroup: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .coordinateSpace(name: id)
            .environment(\.interactionGroupCoordinateSpace, .named(id))
            .onPreferenceChange(InteractionHoverElementPreference.self){ elements = $0 }
            .resetPreference(InteractionHoverElementPreference.self)
            .onChangePolyfill(of: isActive){
                if !isActive {
                    if let previousIndex = elements.firstIndex(where: { $0.id == previousID }) {
                        elements[previousIndex](.left)
                        action(.init(date: Date(), phase: .exited))
                        previousID = nil
                    }
                    action(.init(date: Date(), phase: .ended))
                }
            }
            .gesture(
                enabled ? priority : .none,
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
                            state = true
                        }
                        .onEnded{ gesture in
                            let location = gesture.location
                            
                            if let index = elements.firstIndex(where: { $0.coordinateSpaceBounds.contains(location) }) {
                                elements[index](.ended)
                                self.previousID = nil
                            }
                        }
                )
            )
    }
    
    
}
