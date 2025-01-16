import SwiftUIKit


public struct NavBarExamples: View {
    
    @State private var barHidden = false
    @State private var showBackAction = false
    @State private var visiblePlacements = Set(NavBarItemMetadata.Placement.allCases)
    @State private var accessorySelection = "A"
    
    private func toggle(for placement: NavBarItemMetadata.Placement) -> some View {
        Toggle(isOn: Binding($visiblePlacements, contains: placement)){
            Text("Show \(placement)")
                .font(.exampleParameterTitle)
        }
        .exampleParameterCell()
    }
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "NavBar"){
            NavBarContainer(backAction: .init(visible: showBackAction, action: {
                DispatchQueue.main.async{
                    showBackAction = false
                }
            })){
                ScrollView {
                    LinearGradient(
                        colors: [.clear, .accentColor.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 1000)
                }
                .navBar(.trailing) {
                    if visiblePlacements.contains(.trailing) {
                        TrailingView()
                    }
                }
                .navBar(.leading) {
                    if visiblePlacements.contains(.leading) {
                        Button("Leading \(accessorySelection)", action: {})
                    }
                }
                .navBar(.title) {
                    if visiblePlacements.contains(.title) {
                        Text("Title")
                            .font(.title2[.bold])
                            .lineLimit(1)
                    }
                }
                .navBar(.accessory){
                    if visiblePlacements.contains(.accessory) {
                        SegmentedPicker(
                            selection: $accessorySelection.animation(.smooth),
                            items: ["A", "B", "X"]
                        ){
                            Text($0)
                        }
                        .controlRoundness(0.6)
                        .transitions(.move(edge: .top).animation(.bouncy), .blur(radius: 10), .opacity)
                    }
                }
                .navBarHidden(barHidden)
                .navBarMaterial{
                    Color.primary.opacity(0.05)
                }
            }
            .animation(.smooth, value: visiblePlacements)
            .presentationIdentityBehaviour(.changeOnUpdate)
        } parameters: {
            ExampleSection("Bar", isExpanded: true){
                Toggle(isOn: $barHidden){
                    Text("Hide")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()

                Toggle(isOn: $showBackAction){
                    Text("Show Back Action")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
            }
            
            ExampleSection("Placements", isExpanded: true){
                toggle(for: .leading)
                toggle(for: .title)
                toggle(for: .trailing)
                toggle(for: .accessory)
            }
            .disabled(barHidden)
        }
    }
    
    
    struct TrailingView: View {
        
        @State private var arbitraryState = false
        
        var body: some View {
            Toggle(isOn: $arbitraryState.animation(.bouncy)){
                if arbitraryState {
                    Text("Unselect")
                        .transition(.scale)
                } else {
                    Text("Select")
                        .transition(.scale)
                }
            }
        }
        
    }
}


#Preview("NavBar") {
    NavBarExamples()
        .previewSize()
}
