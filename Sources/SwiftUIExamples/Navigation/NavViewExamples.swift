import SwiftUIKit


public struct NavViewExamples: View {
   
    public init(){}
    
    public var body: some View {
        Content()
    }
    
    struct Content: View {
        
        @Environment(\.reset) private var reset
        @State private var layout: LayoutDirection = .leftToRight
        @State private var useCustomTransition = false
        @State private var useNavBar = true
        
        public var body: some View {
            ExampleView(title: "Nav View"){
                Group {
                    if useCustomTransition {
                        NavView(transition: CustomTransition.self, useNavBar: useNavBar) {
                            Destination(color: .random)
                        }
                    } else {
                        NavView(useNavBar: useNavBar) {
                            Destination(color: .random)
                        }
                    }
                }
                .environment(\.layoutDirection, layout)
            } parameters: {
                Toggle(isOn: $useCustomTransition){
                    Text("Use Custom Transition")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                Toggle(isOn: $useNavBar){
                    Text("Use Nav Bar")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                HStack {
                    Text("Reset Action")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Button("Trigger", action: { reset() })
                }
                .exampleParameterCell()
                
                ExampleCell.LayoutDirection(value: $layout)
            }
        }
        
    }
    
    
    struct Destination: View {
        
        @State private var valueToPresent: Color?
        @State private var test = false
        
        let color: Color
        
        var body: some View {
            ReadableScrollView {
                color
                    .frame(height: 400)
                    .ignoresSafeArea()
                    .overlay {
                        Button("Next"){
                            valueToPresent = .random
                        }
                        .buttonStyle(.bar)
                    }
            }
            .navDestination(value: $valueToPresent){
                Destination(color: $0)
            }
            .navBarTitle(Text(color.description))
            .navBarTrailing{
                Button{ print("A") } label: { Text("A") }
            }
            .navBarTrailing{
                Toggle(isOn: $test){ Text("B") }
            }
            .navBarTrailing{
                Button{ print("C") } label: { Text("C") }
            }
        }
    }
    
}


#Preview("NavView") {
    NavViewExamples()
        .previewSize()
}



struct CustomTransition : TransitionModifier {

    let pushAmount: Double
    
    init(pushAmount: Double) {
        self.pushAmount = pushAmount
    }
    
    func body(content: Content) -> some View {
        content
            .blur(radius: pushAmount * 20)
            .opacity(1 - pushAmount)
            .scaleEffect(1 - (0.1 * pushAmount), anchor: .top)
    }
        
}
