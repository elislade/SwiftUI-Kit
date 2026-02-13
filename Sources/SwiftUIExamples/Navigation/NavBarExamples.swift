import SwiftUIKit


public struct NavBarExamples: View {
    
    @State private var barHidden = false
    @State private var placements = Set(NavBarItemMetadata.Placement.allCases)
    @State private var selection = "A"
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "NavBar"){
            NavBarContainer{
                ReadableScrollView {
                    Rectangle()
                        .fill(.tint)
                        .mask {
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        .ignoresSafeArea()
                        .frame(height: 1000)
                }
                .navBar(.trailing, hidden: !placements.contains(.trailing)) {
                    TrailingView()
                        .minimumScaleFactor(0.5)
                }
                .navBar(.leading, hidden: !placements.contains(.leading)) {
                    LeadingView(selection: $selection.animation(.bouncy))
                        .minimumScaleFactor(0.5)
                }
                .navBar(.title, hidden: !placements.contains(.title)) {
                    Text("Title")
                        .font(.title2[.bold])
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .navBar(.accessory, hidden: !placements.contains(.accessory)){
                    AccessoryView(selection: $selection)
                        .minimumScaleFactor(0.5)
                        .transition(
                            (.scale(y: 0, anchor: .top) + .opacity)
                            .animation(.fastSpringInterpolating)
                        )
                }
                .navBarHidden(barHidden)
            }
            .scrollPassthroughContext()
        } parameters: {
            ExampleSection(isExpanded: true){
                Toggle(isOn: $barHidden){
                    Text("Hide")
                }
            } label: {
                Text("Bar")
            }
            
            ExampleSection(isExpanded: true){
                ForEach(NavBarItemMetadata.Placement.allCases, id: \.rawValue){ placement in
                    Toggle(isOn: Binding($placements, contains: placement)){
                        Text(verbatim: "Show \(placement)")
                    }
                }
            } label: {
                Text("Placements")
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
