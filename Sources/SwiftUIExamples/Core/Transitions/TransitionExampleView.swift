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
            ExampleSection(isExpanded: true) {
                HStack {
                    Toggle(isOn: $show){
                        Text("Show")
                    }
                    
                    ExampleSlider(value: .init($speed, in: (0.1)...(1.7))){
                        Text("Speed")
                    }
                }
            } label: {
                Text("Animation")
            }

            ExampleSection(isExpanded: true) {
                Provider { normal, inverse in
                    transition = normal
                    self.inverse = inverse
                }
            } label: {
                Text("Parameters")
            }
        }
    }
    
}

protocol TransitionProviderView: View {
    
    static var name: String { get }
    
    init(update: @escaping(_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void)
    
}
