import SwiftUIKit


public struct NavBarStyleExamples : View {
    
    @State private var controlSize: ControlSize = .regular
    @State private var controlRondness: Double = 1
    @State private var colorScheme: ColorScheme = .light
    @State private var layoutDirection: LayoutDirection = .leftToRight
    
    public init(){ }
    
    public var body: some View {
        ExampleView(title: "NavBar Styles") {
            VStack {
                HStack {
                    Button("Item A"){}
                    
                    Button(action: {}){
                        Label{ Text("Back") } icon: {
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                                .overlay {
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .offset(x: 2)
                                }
                        }
                        .labelStyle(.iconOnly)
                    }
                }
                
                HStack {
                    InlineBinding(true){ b in
                        Toggle(isOn: b){
                            Text(b.wrappedValue ? "ON" : "OFF")
                                .contentTransitionNumericText()
                        }
                    }
                    
                    InlineBinding(false){
                        Toggle(isOn: $0){
                            Label("Alpha", systemImage: "a.circle")
                            //.labelStyle(.titleOnly)
                        }
                    }
                }
            }
            .buttonStyle(.navBarStyle)
            .toggleStyle(.navBarStyle)
            .environment(\.layoutDirection, layoutDirection)
            .environment(\.controlSize, controlSize)
            .environment(\.controlRoundness, controlRondness)
            .preferredColorScheme(colorScheme)
        } parameters: {
            ExampleCell.ControlRoundness(value: $controlRondness)
            ExampleCell.ControlSize(value: $controlSize)
            ExampleCell.LayoutDirection(value: $layoutDirection)
            ExampleCell.ColorScheme(value: $colorScheme)
        }
    }
}


#Preview {
    NavBarStyleExamples()
        .previewSize()
}
