import SwiftUIKit


public struct ContextMenuExamples: View  {
        
    @State private var presentedIndices: Set<Int> = []
    @State private var optionSelected: Bool = false
    
    public init() {}
    
    public var body: some View {
        ExampleView("Context Menu"){
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: 180))]){
                    ForEach(0..<15){ i in
                        ContainerRelativeShape()
                            .fill(.tint)
                            .opacity(0.1 + Double(i) / 15)
                            .background(.background)
                            .aspectRatio(1, contentMode: .fit)
                            .customContextMenu(isPresented: Binding($presentedIndices, contains: i)) {
                                
                                Button{} label: {
                                    Label { Text("Item A") } icon: {
                                        Image(systemName: "a.circle")
                                    }
                                }
                                
                                MenuGroupDivider()
                                
                                Toggle(isOn: $optionSelected){
                                    Label { Text("Option") } icon: {
                                        Image(systemName: "dog.fill")
                                    }
                                }
                                
                                MenuDivider()
                                
                                Menu {
                                    Label("Title", systemImage: "car")
                                } label: {
                                    Label { Text("Menu B") } icon: {
                                        Image(systemName: "b.circle")
                                    }
                                }
                            } preview: {
                               RoundedRectangle(cornerRadius: 20)
                                    .fill(.tint)
                                    .opacity(0.1 + Double(i) / 15)
                                    .background(
                                        .background,
                                        in: RoundedRectangle(cornerRadius: 20)
                                    )
                                    .shadow(radius: 20, y: 10)
                                    .overlay{
                                        EdgeHighlightSmallMaterial(RoundedRectangle(cornerRadius: 20))
                                    }
                                    .transition(.scale(0.8) + .opacity)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
}


#Preview("Context Menu") {
    ContextMenuExamples()
        .previewSize()
}
