import SwiftUIKit


struct NavBarExamples: View {
    
    @State private var customBarColor: Color = .random
    @State private var barHidden = false
    @State private var showBackAction = false
    @State private var visiblePlacements = Set(NavBarItemMetadata.Placement.allCases)
    
    @State private var accessorySelection = "A"
    
    private func view(for placement: NavBarItemMetadata.Placement) -> some View {
        Toggle(isOn: .init(
            get: { visiblePlacements.contains(placement) },
            set: {
                if $0 {
                    visiblePlacements.insert(placement)
                } else {
                    visiblePlacements.remove(placement)
                }
            }
        )){
            Text("Show \(placement)")
                .font(.exampleParameterTitle)
        }
        .padding()
    }
    
    var body: some View {
        ExampleView(title: "NavBar"){
            NavBarContainer(
                backAction: showBackAction ? { showBackAction = false } : nil
            ){
                ZStack {
                    Color.clear
                    
                    Image(systemName: "photo.fill")
                        .font(.system(size: 72))
                        .opacity(0.2)
                }
                .navBar(.trailing, identity: .stable) {
                    if visiblePlacements.contains(.trailing) {
                        StableIdentityView()
                    }
                }
                .navBar(.leading, identity: .changeOnUpdate) {
                    if visiblePlacements.contains(.leading) {
                        Button("Leading \(accessorySelection)", action: {})
                    }
                }
                .navBar(.title, identity: .custom(visiblePlacements.contains(.title))) {
                    if visiblePlacements.contains(.title) {
                        Text("Title")
                            .font(.title2[.bold])
                            .lineLimit(1)
                    }
                }
                .navBar(.accessory, identity: .changeOnUpdate){
                    if visiblePlacements.contains(.accessory) {
                        SegmentedPicker(
                            selection: $accessorySelection.animation(.smooth),
                            items: ["A", "B", "X"]
                        ){
                            Text($0)
                        }
                        .controlRoundness(0.6)
                    }
                }
                .navBarHidden(barHidden)
                .navBarMaterial{
                    VStack(spacing: 0){
                        customBarColor
                            .opacity(0.8)
                            .saturation(0.1)
                        Divider()
                    }
                }
            }
        } parameters: {
            ExampleSection("Bar", isExpanded: true){
                ColorPicker(selection: $customBarColor){
                    Text("Color")
                        .font(.exampleParameterTitle)
                }
                .padding()
                
                Divider()
               
                Toggle(isOn: $barHidden){
                    Text("Hide")
                        .font(.exampleParameterTitle)
                }
                .padding()
                
                Divider()
                
                Toggle(isOn: $showBackAction){
                    Text("Show Back Action")
                        .font(.exampleParameterTitle)
                }
                .padding()
            }
            
            Divider()
            
            ExampleSection("Placements", isExpanded: true){
                Divider()
                view(for: .leading)
                Divider()
                view(for: .title)
                Divider()
                view(for: .trailing)
                Divider()
                view(for: .accessory)
            }
            .disabled(barHidden)
        }
    }
    
    
    struct StableIdentityView: View {
        
        @State private var arbitraryState = false
        
        var body: some View {
            Toggle(arbitraryState ? "Unselect" : "Select", isOn: $arbitraryState)
                //.contentTransitionIdentity()
                //.animation(.smooth, value: arbitraryState)
        }
        
    }
}


#Preview("NavBar") {
    NavBarExamples()
}
