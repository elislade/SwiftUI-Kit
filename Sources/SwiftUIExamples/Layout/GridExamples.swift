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
    
    @State private var colors = Array(repeating: 0, count: 3).map{ _ in Color.random }
    @State private var spacing = 0.0
    @State private var columns = 4
    
    private func add(){
        withAnimation(.fastSpring){
            colors.append(Color.random)
        }
    }
    
    private func remove(_ color: Color? = nil){
        guard !colors.isEmpty else { return }
        withAnimation(.fastSpring){
            guard let color else {
                colors.removeLast()
                return
            }
            
            colors.removeAll(where: { $0 == color })
        }
    }
    
    private var grid: some View {
        ScrollView([.horizontal, .vertical]){
            GridView(colors, spacing: spacing, columns: columns){ color in
                Button(action: { remove(color) }){
                    color.frame(width: 70, height: 70)
                }
                .buttonStyle(.plain)
                .transitions(
                    .insertion(
                        .scale(0.5),
                        .rotation3D(axis: .y),
                        .offset(x: 400),
                        .blur()
                    ),
                    .removal(.hinge(.random()))
                )
            }
        }
    }
    
    var body: some View {
        ExampleView(title: "Grid View"){
            grid
                .animation(.bouncy, value: columns)
        } parameters: {
            HStack {
                Text("Columns").font(.exampleParameterTitle)
                Text("\(columns)")
                    .font(.exampleParameterValue)
                    .foregroundStyle(.secondary)
                
                Spacer()
                Stepper(value: $columns, in: 1...5)
            }.padding()
            
            Divider()
            
            HStack {
                Text("Count").font(.exampleParameterTitle)
                Text("\(colors.count)")
                    .font(.exampleParameterValue)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Stepper(
                    onIncrement: add,
                    onDecrement: !colors.isEmpty ? { remove() } : nil
                )
            }
            .padding()
            
            Divider()
            
            VStack {
                HStack(spacing: 16) {
                    Text("Spacing").font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(spacing, format: .number)
                        .font(.exampleParameterValue)
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $spacing, in: 0...50, step: 1)
            }
            .padding()
        }
        .contentTransitionNumericText()
        .onAppear{
            for i in 0...10 {
                withAnimation(.bouncy.delay(Double(i) / 10)){
                    colors.append(Color.random)
                }
            }
        }
    }
    
}


#Preview("Grid View") {
    GridViewExample()
}
