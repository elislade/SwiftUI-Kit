import SwiftUIKit


public struct NavViewExamples: View {
   
    @State private var layout: LayoutDirection = .leftToRight
    @State private var valueToPresent: Color?
    @State private var useCustomTransition = false
    @State private var useNavBar = true
    @State private var resetAction: ResetAction?
    
    private var content: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()

            Button("Next"){
                valueToPresent = .random
            }
        }
        .navBarTitle("Hello")
        .navDestination(value: $valueToPresent){
            Destination(color: $0)
                .navBarTitle($0.description)
        }
    }
    
    
    public var body: some View {
        ExampleView(title: "Nav View"){
            Group {
                if useCustomTransition {
                    NavView(transition: CustomTransition(), useNavBar: useNavBar) {
                        content
                    }
                } else {
                    NavView(useNavBar: useNavBar) {
                        content
                    }
                }
            }
            .childResetAction{ _resetAction.wrappedValue = $0 }
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
                
                Button("Trigger", action: { resetAction?() })
                    .disabled(resetAction == nil)
            }
            .exampleParameterCell()
            
            ExampleCell.LayoutDirection(value: $layout)
        }
    }
    
    
    struct Destination: View {
        @State private var valueToPresent: Color?
        
        let color: Color
        var body: some View {
            ZStack {
                color.ignoresSafeArea()
                
                Button("Next"){
                    valueToPresent = .random
                }
            }
            .navDestination(value: $valueToPresent){
                Destination(color: $0)
                    .navBarTitle($0.description)
            }
        }
    }
    
}


#Preview("NavView") {
    NavViewExamples()
        .previewSize()
}



struct CustomTransition : TransitionProvider {
    
    func modifier(_ state: SwiftUINav.TransitionState) -> some ViewModifier {
        Modifier(state: state)
    }
    
    struct Modifier : ViewModifier {
        
        let state: SwiftUINav.TransitionState
        
        func body(content: Content) -> some View {
           GeometryReader { proxy in
                content
                    .hinge(degrees: state.value * 90, edge: .trailing)
                    .offset(x: state.value * -proxy.size.width)
                    .ignoresSafeArea()
            }
           .paddingAddingSafeArea()
        }
        
    }
    
}
