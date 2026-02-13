import SwiftUIKit


#Preview("Grid Stack") {
    InlineBinding("ABCDEFGHIJKLMNOP".map{ $0 }){ state in
        GridStack(state.wrappedValue){ d in
            if let d {
                Button(action: { state.wrappedValue.removeAll(where: { $0 == d }) }){
                    Color.random
                        .frame(width: 70, height: 70)
                        .overlay{
                            Text(String(d))
                        }
                }
                .font(.title2)
                .foregroundStyle(.white)
                .transitions(.scale)
            }
        }
        .animation(.fastSpring, value: state.wrappedValue)
    }
    .buttonStyle(.plain)
}


struct GridViewExample : View {
    
    @State private var numberOfItems = 3
    @State private var spacing = 0.0
    @State private var columns = 4
    
    private var grid: some View {
        ScrollView([.horizontal, .vertical]){
            GridView(0..<numberOfItems, spacing: spacing, columns: columns){ i in
                Button(action: {  }){
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.tint)
                        .opacity(Double(i + 1) / Double(numberOfItems))
                        .frame(width: 70, height: 70)
                }
                .buttonStyle(.plain)
                .transition(
                    .insertion(
                        .scale(0.5),
                        .rotation3D(axis: .y),
                        .offset(x: 400),
                        .blur()
                    )
                    + .removal(.hinge(.random()))
                )
            }
        }
    }
    
    var body: some View {
        ExampleView(title: "Grid View"){
            grid
                .animation(.bouncy, value: columns)
                .animation(.bouncy, value: numberOfItems)
        } parameters: {
            ExampleStepper(value: $columns, range: 1...5){
                Text("Columns")
            }
            
            ExampleStepper(value: $numberOfItems, range: 0...20){
                Text("Count")
            }

            ExampleSlider(value: .init($spacing, in: 0...50, step: 1)){
                Text("Spacing")
            }
        }
        .contentTransitionNumericText()
        .task{
            for _ in 0...10 {
                try? await Task.sleep(for: .seconds(0.05))
                withAnimation(.bouncy){
                    numberOfItems += 1
                }
            }
        }
    }
    
}


#Preview("Grid View") {
    GridViewExample()
        .previewSize()
}
