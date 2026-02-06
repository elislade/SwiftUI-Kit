import SwiftUIKit


public struct ContextMenuExamples: View  {
        
    @State private var optionSelected: Bool = false
    
    public init() {}
    
    struct Item: View {
        
        @State private var isPresented: Bool = false
        
        let index: Int
        @Binding var optionSelected: Bool
        
        var body: some View {
            RoundedRectangle(cornerRadius: 30)
                .fill(.tint)
                .opacity(0.1 + Double(index) / 15)
                .aspectRatio(1, contentMode: .fit)
                .contextMenuX(isPresented: $isPresented) {
                    InnerMenu(optionSelected: $optionSelected)
                }
                preview: {
                    Preview(index: index)
                }
                .onTapGesture {
                    isPresented.toggle()
                }
        }
        
        struct Preview: View {
            
            let index: Int
            
            var body: some View {
                let shape = RoundedRectangle(cornerRadius: 30)
                HStack(spacing: 10) {
                    shape
                        .fill(.tint)
                        .opacity(0.1 + Double(index) / 15)
                        .background(
                            .background,
                            in: shape
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .overlay{
                            EdgeHighlightSmallMaterial(shape)
                        }
                }
                .clipShape(ContainerRelativeShape())
                .containerShape(shape)
                .background{
                    shape.fill(.background)
                }
            }
        }
    }
    
    public var body: some View {
        ExampleView("Context Menu"){
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 100))]){
                    ForEach(0..<21){ i in
                       Item(index: i, optionSelected: $optionSelected)
                    }
                }
                .padding()
            }
            .background()
            .presentationContext()
        }
    }
    
    struct InnerMenu: View {
        
        @Binding var optionSelected: Bool
        @State private var showAsync = false
        
        var body: some View {
            Button{ } label: {
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
                Button{ } label: {
                    Label("Title", systemImage: "car")
                }
            } label: {
                Label { Text("Menu B") } icon: {
                    Image(systemName: "b.circle")
                }
            }
            .preferredLayoutSizePadding(.vertical, showAsync ? 0 : 50)
            .task(priority: .low) { @MainActor in
                try? await Task.sleep(for: .seconds(1.3))
                withAnimation(.smooth){
                    showAsync = true
                }
            }
            
            if showAsync {
                Button{ } label: {
                    Label("Async Item", systemImage: "clock")
                }
                //.disabled(!showAsync)
            }
        }
    }
    
}


#Preview("Context Menu") {
    ContextMenuExamples()
        .previewSize()
}
