import SwiftUI


struct WindowInteractionHoverContext: ViewModifier {
    
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    
    @State private var previousID: UUID?
    @State private var enabled = false
    
    let hapticsEnabled: Bool
    let hitTestOnStart: Bool
    
    func body(content: Content) -> some View {
        content.overlayPreferenceValue(WindowInteractionHoverElementPreference.self){ elements in
            GeometryReader{ proxy in
                if !elements.isEmpty && !isBeingPresentedOn {
                    Color.clear.onWindowDrag{ evt in
                        guard let location = evt.locations.first else { return }
                        
                        if hitTestOnStart {
                            if evt.phase == .began {
                                enabled = proxy.frame(in: .global).contains(location)
                            }
                        } else {
                            enabled = true
                        }
                        
                        defer {
                            if evt.phase == .ended {
                                enabled = false
                            }
                        }
                        
                        guard enabled else { return }
                        
                        if let index = elements.firstIndex(where: { $0.windowBounds.contains(location) }) {
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
                            } else {
                                if previousID != id {
                                    if let previousIndex = elements.firstIndex(where: { $0.id == previousID }) {
                                        elements[previousIndex](.left)
                                    }
                                    
                                    elements[index](.entered)
                                    previousID = id
                                }
                            }
                        } else if let previousIndex = elements.firstIndex(where: { $0.id == previousID }) {
                            elements[previousIndex](.left)
                            self.previousID = nil
                        }
                    }
                    .onDisappear{
                        previousID = nil
                        enabled = false
                    }
                }
            }
        }
        .resetPreference(WindowInteractionHoverElementPreference.self)
        .background{
            if hapticsEnabled {
                Color.clear.sensoryFeedbackPolyfill(value: previousID)
            }
        }
    }
    
}
