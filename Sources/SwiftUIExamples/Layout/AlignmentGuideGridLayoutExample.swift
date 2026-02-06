import SwiftUIKit


public struct AlignmentGuideGridLayoutExample : View {
    
    struct Element<Value>: Identifiable {
        let id: UniqueID
        let value: Value
        
        init(_ value: Value) {
            self.id = .init()
            self.value = value
        }
    }
    
    @State private var elements: [Element<Double>] = (0..<3).map{ _ in
        .init(.random(in: 0...1))
    }
    
    @State private var spacing: Double = 5
    @State private var columns: Int = 4
    
    public init() {}
    
    private func add(){
        elements.append(.init(.random(in: 0...1)))
    }
    
    private func remove(){
        guard !elements.isEmpty else { return }
        elements.removeLast()
    }
    
    private var layout: some RelativeCollectionLayoutModifier {
        AlignmentGuideGridLayout(spacing: spacing, columns: columns)
    }
    
    private var grid: some View {
        ScrollView([.horizontal, .vertical]){
            ZStackCollectionLayout(layout, data: elements){ element in
                Button {
                    elements.removeAll(where: { $0.id == element.id })
                } label: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.tint)
                        .opacity(element.value)
                        .background{
                            RoundedRectangle(cornerRadius: 16)
                        }
                        .frame(width: 70, height: 70)
                }
                .buttonStyle(.plain)
                .transition(
                    .insertion(
                        .scale(0.5),
                        .rotation3D(axis: .y),
                        .offset(x: 400),
                        .blur(radius: 10).animation(.linear)
                    )
                    + .removal(.hinge(.random()))
                    + .opacity.animation(.linear)
                )
            }
        }
    }
    
    public var body: some View {
        ExampleView(title: "AlignmentGuide Grid Layout"){
            grid
                .animation(.bouncy, value: elements.count)
                .animation(.bouncy, value: columns)
        } parameters: {
            HStack {
                Text("Columns").font(.exampleParameterTitle)
                Spacer()
                Text("\(columns)")
                    .font(.exampleParameterValue)
                    .foregroundStyle(.secondary)
                
                Stepper(value: $columns, in: 1...5)
            }
            .exampleParameterCell()
            
            HStack {
                Text("Count").font(.exampleParameterTitle)
                
                Spacer()
                
                Text(elements.count, format: .number)
                    .font(.exampleParameterValue)
                    .foregroundStyle(.secondary)
                
                Stepper(
                    onIncrement: add,
                    onDecrement: !elements.isEmpty ? { remove() } : nil
                )
            }
            .exampleParameterCell()
            
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
            .exampleParameterCell()
        }
        .contentTransitionNumericText()
        .task{ @MainActor in
            for _ in 0...10 {
                try? await Task.sleep(for: .seconds(0.05))
                add()
            }
        }
    }
    
}


#Preview("Alignment Guide Grid Layout Example") {
    AlignmentGuideGridLayoutExample()
        .previewSize()
}
