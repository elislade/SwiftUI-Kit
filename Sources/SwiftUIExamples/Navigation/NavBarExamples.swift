import SwiftUIKit


public struct NavBarExamples: View {
    
    @State private var barHidden = false
    @State private var placements = Set(NavBarItemMetadata.Placement.allCases)
    @State private var selection = "A"
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "NavBar"){
            NavBarContainer{
                ScrollView {
                    Rectangle()
                        .fill(.tint)
                        .mask {
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        .frame(height: 1000)
                }
                .ignoresSafeArea(edges: [.horizontal, .bottom])
                .navBar(placements.contains(.trailing) ? .trailing : .none) {
                    TrailingView()
                        .minimumScaleFactor(0.5)
                }
                .navBar(placements.contains(.leading) ? .leading : .none) {
                    LeadingView(selection: $selection.animation(.bouncy))
                        .minimumScaleFactor(0.5)
                }
                .navBar(placements.contains(.title) ? .title : .none) {
                    Text("Title")
                        .font(.title2[.bold])
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .navBar(placements.contains(.accessory) ? .accessory : .none){
                    AccessoryView(selection: $selection)
                        .minimumScaleFactor(0.5)
                        .transition(
                            (.scale(y: 0, anchor: .top) + .opacity)
                            .animation(.fastSpringInterpolating)
                        )
                }
                .navBarHidden(barHidden)
            }
        } parameters: {
            ExampleSection("Bar", isExpanded: true){
                Toggle(isOn: $barHidden){
                    Text("Hide")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
            }
            
            ExampleSection("Placements", isExpanded: true){
                ForEach(NavBarItemMetadata.Placement.allCases, id: \.rawValue){ placement in
                    if placement != .none {
                        Toggle(isOn: Binding($placements, contains: placement)){
                            Text("Show \(placement)")
                                .font(.exampleParameterTitle)
                        }
                        .exampleParameterCell()
                    }
                }
            }
            .disabled(barHidden)
        }
    }
    
    
    struct LeadingView: View {
        
        @Binding var selection: String
        
        var body: some View {
            Button("Leading \(selection)", action: { selection = "A" })
                .contentTransitionNumericText()
        }
    }
    
    
    struct TrailingView: View {
        
        @State private var arbitraryState = false
        
        var body: some View {
            Toggle(isOn: $arbitraryState.animation(.bouncy)){
                Text(arbitraryState ? "Unselect" : "Select")
                    .contentTransitionNumericText()
            }
        }
        
    }
    
    
    struct AccessoryView: View {
        
        @Binding var selection: String
        
        var body: some View {
            SegmentedPicker(
                selection: $selection.animation(.smooth),
                items: ["A", "B", "C"]
            ){
                Text($0)
            }
            .controlRoundness(0.8)
        }
    }
    
}


#Preview("NavBar") {
    NavBarExamples()
        .previewSize()
}
