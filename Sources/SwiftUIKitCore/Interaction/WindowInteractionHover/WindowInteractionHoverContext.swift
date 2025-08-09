import SwiftUI


struct WindowInteractionHoverContext: ViewModifier {
    
    let hapticsEnabled: Bool
    
    @State private var previousID: UUID?
    
    func body(content: Content) -> some View {
        content.overlayPreferenceValue(WindowInteractionHoverElementPreference.self){ elements in
            if !elements.isEmpty {
                Color.clear.onWindowDrag{ evt in
                    guard let location = evt.locations.first else { return }
                    
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
                }
            }
        }
        .background{
            if hapticsEnabled {
                Color.clear.sensoryFeedbackPolyfill(value: previousID)
            }
        }
    }
    
}
