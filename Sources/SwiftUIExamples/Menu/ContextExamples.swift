import SwiftUIKit


struct ContextMenuExamples: View  {
        
    @State private var presentedIndices: Set<Int> = []
    @State private var tint: Color = .random
    
    private func binding(for index: Int) -> Binding<Bool> {
        .init(
            get: { presentedIndices.contains(index) },
            set: {
                if $0 {
                    presentedIndices.insert(index)
                } else {
                    presentedIndices.remove(index)
                }
            }
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: 180))]){
                    ForEach(0...15){ i in
                        Rectangle()
                            .fill(.tint)
                            .opacity(0.1 + Double(i) / 15)
                            .background(.background)
                            .aspectRatio(1, contentMode: .fit)
                            .contextCustomMenu(isPresented: binding(for: i)) {
                                Button(action: {}){
                                    Text("Item A")
                                        .applyMenuItemInsets()
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
