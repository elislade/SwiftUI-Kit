import SwiftUI


struct InteractionHoverWindowGroup {
    
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    
    @State private var previousID: UUID?
    @State private var enabled = false
    @State private var elements: [InteractionHoverElement] = []
    @State private var frame: CGRect = .zero
    
    let hapticsEnabled: Bool
    let hitTestOnStart: Bool
    let action: (InteractionHoverGroupEvent) -> Void
    
}


extension InteractionHoverWindowGroup: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .environment(\.interactionGroupCoordinateSpace, .global)
            .preferenceChangeConsumer(InteractionHoverElementPreference.self){ elements = $0 }
            .onWindowDrag{ evt in
                guard
                    !elements.isEmpty && !isBeingPresentedOn,
                    let location = evt.locations.first
                else {
                    previousID = nil
                    enabled = false
                    return
                }

                if hitTestOnStart {
                    if evt.phase == .began {
                        enabled = frame.contains(location)
                        if enabled {
                            action(.init(date: Date(), phase: .started))
                        }
                    }
                } else {
                    if !enabled {
                        action(.init(date: Date(), phase: .started))
                    }
                    enabled = true
                }

                defer {
                    if evt.phase == .ended {
                        enabled = false
                    }
                }

                guard enabled else { return }

                if let index = elements.firstIndex(where: { $0.coordinateSpaceBounds.contains(location) }) {
                    let id = elements[index].id

                    if evt.phase == .ended {
                        if
                            id != previousID,
                            let previousIndex = elements.firstIndex(where: { $0.id == previousID })
                        {
                            elements[previousIndex](.left)
                        }

                        elements[index](.ended)
                        previousID = nil
                        action(.init(date: Date(), phase: .ended))
                    } else {
                        if previousID != id {
                            if let previousIndex = elements.firstIndex(where: { $0.id == previousID }) {
                                elements[previousIndex](.left)
                                action(.init(date: Date(), phase: .exited))
                            }

                            elements[index](.entered)
                            action(.init(date: Date(), phase: .entered))
                            previousID = id
                        }
                    }
                } else if let previousIndex = elements.firstIndex(where: { $0.id == previousID }) {
                    elements[previousIndex](.left)
                    self.previousID = nil
                    action(.init(date: Date(), phase: .exited))
                }
            }
            .background{
                if hapticsEnabled {
                    Color.clear.sensoryFeedbackPolyfill(value: previousID)
                }
            }
    }
    
}
