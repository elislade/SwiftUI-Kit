import SwiftUIKit


struct TransitionExampleView<Provider: TransitionProviderView>: View {
    
    @State private var inverse: AnyTransition?
    @State private var transition: AnyTransition = .identity
    @State private var show = false
    @State private var speed: Double = 1
    
    var body: some View {
        ExampleView(title: Provider.name){
            ZStack{
                Color.clear
                
                if show {
                    ContainerRelativeShape()
                        .fill(.tint)
                        .transition(transition)
                } else if let inverse {
                    ContainerRelativeShape()
                        .fill(.tint)
                        .transition(inverse)
                }
            }
            .padding()
            .animation(.smooth(extraBounce: 0.5).speed(speed), value: show)
        } parameters: {
            Toggle(isOn: $show){
                Text("Show")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()

            VStack {
                HStack{
                    Text("Speed")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(speed, format: .increment(0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $speed, in: (0.1)...(1.7))
            }
            .exampleParameterCell()
            
            Provider { normal, inverse in
                transition = normal
                self.inverse = inverse
            }
        }
    }
    
}

protocol TransitionProviderView: View {
    
    static var name: String { get }
    
    init(update: @escaping(_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void)
    
}
