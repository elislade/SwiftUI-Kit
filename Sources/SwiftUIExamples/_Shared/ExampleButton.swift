import SwiftUIKit


struct ExampleButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isHighlighted) private var isHighlighted
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed || isHighlighted
        let isDestructive = configuration.role == .destructive
        configuration.label
            .labelStyle(.viewThatFits(preferring: \.title))
            .font(.exampleParameterTitle)
            .foregroundStyle(isDestructive ? pressed ? .primary : Color.red : .primary)
            .frame(height: .controlSize)
            .padding(.horizontal, 12)
            .opacity(isEnabled ? 1 : 0.5)
            .background{
                SunkenControlMaterial(ContainerRelativeShape())
                    .scaleEffect(y: -1)
                    .opacity(isEnabled ? 1 : 0.5)
        
                ContainerRelativeShape()
                    .opacity(0.1)
                
                if pressed {
                    ContainerRelativeShape()
                        .inset(by: 2)
                        .fill(isDestructive ? AnyShapeStyle(.red) : AnyShapeStyle(.tint))
                        .blendMode(.overlay)
                        //.transition(.moveEdgeIgnoredByLayout(.leading).animation(.bouncy))
                }
            }
            .compositingGroup()
            .clipShape(ContainerRelativeShape())
            .containerShape(PercentageRoundedRectangle(.vertical, percentage: 0.7))
    }
    
}


extension ButtonStyle where Self == ExampleButtonStyle {
    
    static var example: ExampleButtonStyle {
         .init()
    }
    
}


struct ExampleToggleStyle: ToggleStyle {
    
    @Environment(\.toggleHintVisibility) private var imageHintVisiblility
    
    func makeBody(configuration: Configuration) -> some View {
        Button{ configuration.isOn.toggle() } label: {
            HStack(spacing: 0) {
                configuration.label
                if imageHintVisiblility != .hidden {
                    Spacer(minLength: 12)
                    Switch(isOn: configuration.$isOn)
//                    Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
//                        .contentTransitionSymbolEffect()
//                        .imageScale(.large)
//                        .symbolRenderingMode(.hierarchical)
                }
            }
            .contentTransitionSymbolEffect()
        }
        .buttonStyle(.example)
        .isHighlighted(configuration.isOn && imageHintVisiblility == .hidden)
    }
    
}



extension ToggleStyle where Self == ExampleToggleStyle {
    
    static var example: ExampleToggleStyle {
         .init()
    }
    
}


extension EnvironmentValues {
    
    @Entry var toggleHintVisibility: Visibility = .automatic
    
}


extension View {
    
    func toggleHintIndicatorVisibility(_ visibility: Visibility) -> some View {
        environment(\.toggleHintVisibility, visibility)
    }
    
}
