import SwiftUIKit


public struct CompositeTransitionExamples: View {
    
    @State private var show = false
    @State private var order: [Int] = Array(0..<8)
    @State private var transitions: [AnyTransition?] = Array(repeating: nil, count: 8)
    
    public init() {}
    
    private var orderedTransitions: [AnyTransition] {
        order.compactMap{ transitions[$0] }
    }
    
    private func reorder(from i: Int, by stride: Int) {
        let targetIndex = (i + stride) % order.count
        if targetIndex < 0 {
            order.swapAt(i, order.count + targetIndex)
        } else {
            order.swapAt(i, targetIndex)
        }
    }
    
    public var body: some View {
        ExampleView(title: "Composite Transition"){
            VStack(spacing: 0) {
                ZStack {
                    Color.clear
                    
                    if show {
                        Color.primary
                            .padding(-1)
                            .transitions(orderedTransitions)
                    }
                }
                
                LoadingLine(state: .progress(show ? 1 : 0))
                    .frame(height: 4)
            }
            .animation(.smooth, value: show)
            .overlay(alignment: .bottom){
                HStack(spacing: 0) {
                    Button(show ? "Hide" : "Show", systemImage: show ? "backward.end" : "forward.end"){
                        show.toggle()
                    }
                    .contentTransitionSymbolEffect()
                    
                    Spacer()
                    
                    Button("Clear", systemImage: "trash", role: .destructive){
                        transitions = Array(repeating: nil, count: 8)
                    }
                }
                .disabled(orderedTransitions.isEmpty)
                .symbolVariant(.circle.fill)
                .padding()
                .font(.largeTitle)
            }
            .ignoresSafeArea()
        } parameters: {
            ForEach(order){ o in
                let i = order.firstIndex(of: o)!
                HStack {
                    Image(systemName: "\(i + 1).circle.fill")
                        .imageScale(.large)
                    
                    if o == 0 {
                        Cell<FlipTransitionExample.Parameters>($transitions[o])
                    } else if o == 1 {
                        Cell<Rotation3DTransitionExample.Parameters>($transitions[o])
                    } else if o == 2 {
                        Cell<ScaleTransitionExample.Parameters>($transitions[o])
                    } else if o == 3 {
                        Cell<OffsetTransitionExample.Parameters>($transitions[o])
                    } else if o == 4 {
                        Cell<BlurTransitionExample.Parameters>($transitions[o])
                    } else if o == 5 {
                        Cell<Rotation2DTransitionExample.Parameters>($transitions[o])
                    } else if o == 6 {
                        Cell<OpacityTransitionExample.Parameters>($transitions[o])
                    } else if o == 7 {
                        Cell<FrameTransitionExample.Parameters>($transitions[o])
                    }
                    
                    VStack(spacing: 5) {
                        Button("Up", systemImage: "chevron.up"){
                            reorder(from: i, by: -1)
                        }
                        
                        Button("Down", systemImage: "chevron.down"){
                            reorder(from: i, by: 1)
                        }
                    }
                    .font(.body[.bold])
                }
                .exampleParameterCell()
            }
            .animation(.smooth, value: order)
        }
        .buttonStyle(.tintStyle)
        .symbolRenderingMode(.hierarchical)
        .labelStyle(.iconOnly)
    }
    
    
    struct Cell<Provider: TransitionProviderView> : View {
        
        @State private var add = false
        @Binding var transition: AnyTransition?
 
        init(_ transition: Binding<AnyTransition?>) {
            _transition = transition
        }
        
        var body: some View {
            HStack(spacing: 0) {
                Text(Provider.name)
                    .font(.exampleParameterTitle)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 10)
                
                if transition != nil {
                    Button("Clear", systemImage: "trash", role: .destructive){
                        self.transition = nil
                    }
                    .font(.title)
                } else {
                    Button("Add", systemImage: "plus"){
                        add = true
                    }
                    .font(.title)
                }
            }
            .symbolVariant(.circle.fill)
            .presentation(isPresented: $add){
                AddParameters<Provider>{ t in
                    transition = t
                    add = false
                }
                .paddingAddingSafeArea(.bottom)
                .background{
                    AsymmetricRoundedRectangle(values: .init(top: 20))
                        .fill(.regularMaterial)
                }
                .transitions(
                    (.opacity + .blur(radius: 10) + .offset([0, 500]))
                        .animation(.fastSpringInterpolating)
                )
            }
        }
    }
    
    
    struct AddParameters<Provider: TransitionProviderView>: View {
        let add: (AnyTransition) -> Void
        
        @State private var transition: AnyTransition?
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(Provider.name)
                        .font(.exampleSectionTitle)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Spacer(minLength: 10)
                    
                    Button("Add", systemImage: "plus.circle.fill"){
                        if let transition {
                            add(transition)
                        }
                    }
                    .disabled(transition == nil)
                    .font(.title)
                }
                .padding()
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 0) {
                        Provider{ t, u in transition = t }
                    }
                }
            }
        }
        
    }
    
    
    struct ClipRoundedRect: View {
        
        let add: (AnyTransition) -> Void
        
        @State private var width: Double = 1
        @State private var anchor = UnitPoint.center
        
        var body: some View {
            VStack {
                HStack {
                    Text("Clip Rounded Rect").font(.exampleParameterTitle)
                    Text(width, format: .number)
                        .font(.exampleParameterValue)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("Add", systemImage: "plus.circle.fill"){
                        add(.clipRoundedRectangle(
                            RoundedRectangle(cornerRadius: width)
                        ))
                    }
                    .font(.title)
                }
                
                Slider(value: $width, in : 0...100, step: 1)
            }
        }
    }

}


#Preview("Composite Transitions") {
    CompositeTransitionExamples()
        .sceneEnvironment()
        .previewSize()
}
