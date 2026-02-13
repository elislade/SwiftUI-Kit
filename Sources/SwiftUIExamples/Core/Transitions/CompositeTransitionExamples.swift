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
            VStack(spacing: 14) {
                Color.clear.overlay {
                    if show {
                        ContainerRelativeShape()
                            .transitions(orderedTransitions)
                    }
                }
                .frame(maxWidth: 600)
                
                HStack(spacing: 0) {
                    Button(role: .destructive){
                        transitions = Array(repeating: nil, count: 8)
                        show = false
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    
                    Spacer()
                    
                    Toggle(isOn: $show){
                        Label("Play", systemImage: show ? "backward.end" : "forward.end")
                    }
                    .toggleHintIndicatorVisibility(.hidden)
                    .contentTransitionSymbolEffect()
                    .keyboardShortcut(.defaultAction)
                }
                .disabled(orderedTransitions.isEmpty)
                .symbolVariant(.fill)
                .toggleStyle(.example)
                .buttonStyle(.example)
            }
            .padding(10)
            .animation(.smooth(extraBounce: 0.2), value: show)
        } parameters: {
            ExampleSection("Parameters", isExpanded: true){
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
                        
                        Capsule()
                            .frame(width: 3, height: 20)
                            .opacity(0.2)
                        
                        HStack(spacing: 5) {
                            Button{ reorder(from: i, by: -1) } label: {
                                Label("Up", systemImage: "chevron.up")
                                    .labelStyle(.iconOnly)
                            }
                            
                            Button{ reorder(from: i, by: 1) } label: {
                                Label("Down", systemImage: "chevron.down")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                }
                .geometryGroupIfAvailable()
            }
            .animation(.smooth, value: order)
        }
    }
    
    
    struct Cell<Provider: TransitionProviderView> : View {
        
        @Environment(\.horizontalSizeClass) private var horizontalSize
        @Environment(\.colorScheme) private var colorScheme
        @State private var add = false
        @Binding var transition: AnyTransition?
 
        init(_ transition: Binding<AnyTransition?>) {
            _transition = transition
        }
        
        var body: some View {
            HStack(spacing: 0) {
                Text(Provider.name)
                    .font(.exampleParameterTitle)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 10)
                
                if transition != nil {
                    Button(role: .destructive){ transition = nil } label: {
                        Label("Clear", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                } else {
                    Button{ add = true } label: {
                        Label("Add", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .presentation(
                isPresented: $add,
                alignment: .bottomTrailing
            ){
                AddParameters<Provider>{ t in
                    transition = t
                    add = false
                }
                .background{
                    AsymmetricRoundedRectangle(
                        values: .init(top: 30, bottom: horizontalSize == .compact ? 0 : 30)
                    )
                    .fill(.regularMaterial)
                    .ignoresSafeArea()
                }
                .colorScheme(colorScheme)
                .frame(
                    maxWidth: horizontalSize == .compact ? nil : 500
                )
                .padding(horizontalSize == .compact ? 0 : 5)
                .transition(
                    .offset([0, 60]).animation(.fastSpringInterpolating)
                    + .moveEdgeIgnoredByLayout(.bottom)
                        .animation(.fastSpringInterpolating)
                    + .scale(anchor: .bottom).animation(.bouncy)
                    + .opacity.animation(.easeInOut)
                )
            }
        }
    }
    
    
    struct AddParameters<Provider: TransitionProviderView>: View {
        
        @Environment(\.dismissPresentation) private var dismiss
        @State private var transition: AnyTransition?
        
        let add: (AnyTransition) -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Text(Provider.name)
                        .font(.exampleSectionTitle)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button{ dismiss() } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                            .labelStyle(.iconOnly)
                    }
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
                }
                .padding()
                .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                    .ignoresSafeArea()
                
                ViewThatFits(in: .vertical){
                    VStack(spacing: 14) {
                        Provider{ t, u in transition = t }
                    }
                    .padding(10)
                    
                    ScrollView {
                        VStack(spacing: 14) {
                            Provider{ t, u in transition = t }
                        }
                        .padding(10)
                    }
                    .frame(maxHeight: 460)
                }
                .buttonStyle(.example)
                .toggleStyle(.example)
                
                Button{
                    if let transition {
                        add(transition)
                    }
                } label: {
                    Label("Add Transition", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .disabled(transition == nil)
                .buttonStyle(.example)
                .padding(10)
                .keyboardShortcut(.defaultAction)
            }
        }
        
    }

}


#Preview("Composite Transitions") {
    CompositeTransitionExamples()
        .previewSize()
}
