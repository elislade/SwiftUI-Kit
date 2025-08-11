import SwiftUIKit


public struct NavBarStyleExamples : View {
    
    @State private var controlSize: ControlSize = .regular
    @State private var controlRondness: Double = 1
    @State private var colorScheme: ColorScheme = .light
    @State private var layoutDirection: LayoutDirection = .leftToRight
    @State private var isOn: Bool = false
    
    public init(){ }
    
    public var body: some View {
        ExampleView(title: "NavBar Styles") {
            VStack {
                HStack {
                    Toggle(isOn: $isOn){
                        Label("Filter", systemImage: "camera.filters")
                    }
                    
                    Toggle(isOn: $isOn){
                        Label("Filter", systemImage: "camera.filters")
                    }
                    .labelStyle(.iconOnly)
                    
                    Toggle(isOn: $isOn){
                        Label("Filter", systemImage: "camera.filters")
                    }
                    .labelStyle(.titleOnly)
                }
                
                HStack {
                    Button{} label: {
                        Label("Filter", systemImage: "camera.filters")
                    }
                    
                    Button{} label: {
                        Label("Filter", systemImage: "camera.filters")
                    }
                    .labelStyle(.iconOnly)
                    
                    Button{} label: {
                        Label("Filter", systemImage: "camera.filters")
                    }
                    .labelStyle(.titleOnly)
                }
            }
            .buttonStyle(.bar)
            .toggleStyle(.bar)
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
