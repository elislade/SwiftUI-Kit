import SwiftUIKit


public struct ContextMenuExamples: View  {
        
    @State private var presentedIndices: Set<Int> = []
    @State private var tint: Color = .random
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: 180))]){
                    ForEach(0...15){ i in
                        Rectangle()
                            .fill(.tint)
                            .opacity(0.1 + Double(i) / 15)
                            .background(.background)
                            .aspectRatio(1, contentMode: .fit)
                            .contextCustomMenu(isPresented: Binding($presentedIndices, contains:  i)) {
                                Button(action: {}){
                                    Text("Item A")
                                        .paddingAddingMenuItemInsets()
                                }
                                
                                MenuGroupDivider()
                                
                                Toggle(isOn: .constant(true)){ Text("Got Dog ?") }
                                
                                MenuDivider()
                                
                                Menu {
                                    Label("Title", systemImage: "car")
                                } label: {
                                    Text("Item B")
                                }
                            }
                    }
                }
                .padding()
            }
            .focusPresentationContext()
            .background(.bar)
            
            Divider().ignoresSafeArea()
            
            ExampleTitle("Context Menu")
                .padding()
        }
        .tint(tint)
    }
    
}


#Preview("Context Menu") {
    ContextMenuExamples()
}
