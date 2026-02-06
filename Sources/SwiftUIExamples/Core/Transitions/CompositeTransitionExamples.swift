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
            Color.clear.overlay {
                if show {
                    ContainerRelativeShape()
                        .transitions(orderedTransitions)
                }
            }
            .overlay(alignment: .bottom){
                HStack(spacing: 0) {
                    Button(show ? "Hide" : "Show", systemImage: show ? "backward.end" : "forward.end"){
                        show.toggle()
                    }
                    .contentTransitionSymbolEffect()
                    .overlay {
                        LoadingCircle(state: .progress(show ? 1 : 0))
                    }
                    
                    Spacer()
                    
                    Button("Clear", systemImage: "trash", role: .destructive){
                        transitions = Array(repeating: nil, count: 8)
                    }
                }
                .disabled(orderedTransitions.isEmpty)
                .symbolVariant(.circle.fill)
                // .padding()
                .font(.largeTitle)
            }
            .padding()
            .animation(.smooth(extraBounce: 0.2), value: show)
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
        .buttonStyle(.tinted)
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
                .background{
                    AsymmetricRoundedRectangle(values: .init(top: 30))
                        .fill(.regularMaterial)
                        .ignoresSafeArea()
                }
                .transition(
                    .offset([0, 60]).animation(.fastSpringInterpolating)
                    + .moveEdgeIgnoredByLayout(.bottom).animation(.fastSpringInterpolating)
                )
            }
        }
    }
    
    
    struct AddParameters<Provider: TransitionProviderView>: View {
        
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.dismissPresentation) private var dismiss
        @State private var transition: AnyTransition?
        
        let add: (AnyTransition) -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment:. top, spacing: 10) {
                    if verticalSizeClass == .compact {
                        Button("Close", systemImage: "xmark.circle.fill"){
                            dismiss()
                        }
                        .font(.title)
                    }
                    
                    Text(Provider.name)
                        .font(.exampleSectionTitle)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("Add", systemImage: "plus.circle.fill"){
                        if let transition {
                            add(transition)
                        }
                    }
                    .disabled(transition == nil)
                    .font(.title)
                }
                .padding()
                .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                    .ignoresSafeArea()
                
                ViewThatFits(in: .vertical){
                    VStack(spacing: 0) {
                        Provider{ t, u in transition = t }
                    }
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            Provider{ t, u in transition = t }
                        }
                    }
                    .frame(maxHeight: 460)
                }
            }
        }
        
    }

}


#Preview("Composite Transitions") {
    CompositeTransitionExamples()
        .previewSize()
}
