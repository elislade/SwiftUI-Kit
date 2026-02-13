import SwiftUIKit

/// - Note: `MouseEventExamples` will not work in Live Previews.
public struct MouseEventExamples: View {
    
    enum MouseEvent: Identifiable, Equatable {
        case scroll(MouseScrollEvent)
        case click(MouseClickEvent)
        
        var id: String {
            switch self {
            case .scroll(let evt): evt.id
            case .click(let evt): evt.id
            }
        }
        
        static func == (lhs: MouseEvent, rhs: MouseEvent) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    @State private var events: [MouseEvent] = []
    @State private var enabled = true
    
    public init(){ }
    
    public var body: some View {
        ExampleView(title: "Mouse Events"){
            ZStack {
                Color.clear
                    .contentShape(Rectangle())

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(events){ event in
                            HStack {
                                switch event {
                                case .scroll(let evt):
                                    Text("Scroll")
                                        .font(.headline)
                                    Spacer()
                                    Text(evt.delta.description)
                                case .click(let evt):
                                    Text("Click")
                                        .font(.headline)
                                    Spacer()
                                    Text(verbatim: "\(evt.phase)")
                                    Text(verbatim: "\(evt.button)")
                                }
                            }
                            .padding()
                            .transitions(.scale, .opacity)
                            
                            Divider()
                        }
                    }
                    .animation(.smooth, value: events)
                }
            }
            .onMouseScroll {
                if enabled {
                    events.insert(.scroll($0), at: 0)
                }
            }
            .onMouseClick {
                if enabled {
                    events.insert(.click($0), at: 0)
                }
            }
        } parameters: {
            Toggle(isOn: $enabled){
                Text("Enabled")
            }
        }
    }
    
}


#Preview {
    MouseEventExamples()
        .previewSize()
}
