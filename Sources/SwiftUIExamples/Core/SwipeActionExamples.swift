import SwiftUIKit


public struct SwipeActionExamples: View {
    
    enum Action: String, CaseIterable, Identifiable {
        var id: RawValue { rawValue }
        
        case delete
        case archive
        case share
        case pin
    }
    
    @State private var layoutDirection: LayoutDirection = .leftToRight
    @State private var cellRadius: Double = 16
    @State private var cells: [HorizontalEdge?] = Array(repeating: nil, count: 5)
    @State private var leadingActions: Set<Action> = [.pin]
    @State private var trailingActions: Set<Action> = [.archive, .delete]
    
    public init() {}
    
    private func binding(for edge: HorizontalEdge) -> Binding<Bool> {
        .init(
            get: { cells[0] == edge },
            set: { cells[0] = $0 ? edge : nil }
        ).transaction($cells.transaction)
    }
    
    public var body: some View {
        ExampleView(title: "Swipe Actions"){
            ScrollView {
                VStack(spacing: cellRadius == 0 ? 0 : 16) {
                    ForEach(cells.indices, id: \.self){ i in
                        let selectedIndex = cells.firstIndex(where: { $0 != nil })
                        let isFaded = selectedIndex != nil && selectedIndex != i
                        Cell(
                            activeEdge: $cells[i],
                            radius: cellRadius,
                            leadingActions: leadingActions,
                            trailingActions: trailingActions
                        )
                        .opacity(isFaded ? 0.5 : 1)
                        .animation(.smooth, value: isFaded)
                        .overlay(alignment: .bottom){
                            if cellRadius == 0 {
                                Divider()
                                    .transition(
                                        .asymmetric(
                                            insertion: .offset([400,0]).animation(.smooth.delay(Double(i) / 8)),
                                            removal: .identity
                                        )
                                    )
                            }
                        }
                    }
                }
                .padding(cellRadius == 0 ? 0 : 16)
                .labelStyle(.iconOnly)
                .animation(.bouncy, value: cellRadius == 0)
            }
            .environment(\.layoutDirection, layoutDirection)
        } parameters: {
            ExampleSection("Cell Style", isExpanded: true){
                VStack(spacing: 0){
                    VStack {
                        HStack {
                            Text("Radius")
                                .font(.exampleParameterTitle)
                            
                            Spacer()
                            
                            Text(cellRadius, format: .number.rounded(increment: 0.1))
                                .monospacedDigit()
                        }
                        
                        Slider(value: $cellRadius, in: 0...50)
                    }
                    .exampleParameterCell()
                    
                    ExampleCell.LayoutDirection(value: $layoutDirection)
                }
            }
            
            ExampleSection("Leading Views", isExpanded: true){
                VStack(spacing: 0){
                    Toggle(isOn: binding(for: .leading)){
                       Text("First Active")
                            .font(.exampleParameterTitle)
                    }
                    .exampleParameterCell()
                    
                    ForEach(Action.allCases, id: \.self){ action in
                        Toggle(isOn: Binding($leadingActions, contains: action)){
                            CellButton(action: action)
                        }
                        .exampleParameterCell()
                    }
                }
            }
            
            ExampleSection("Trailing Views", isExpanded: true){
                VStack(spacing: 0){
                    Toggle(isOn: binding(for: .trailing)){
                       Text("First Active")
                            .font(.exampleParameterTitle)
                    }
                    .exampleParameterCell()
                    
                    ForEach(Action.allCases, id: \.self){ action in
                        Toggle(isOn: Binding($trailingActions, contains: action)){
                            CellButton(action: action)
                        }
                        .exampleParameterCell()
                    }
                }
            }
        }
    }
    
    
    struct CellButton: View {
        let action: Action
        
        var tint: Color {
            switch action {
            case .delete: .red
            case .archive: .orange
            case .share: .blue
            case .pin: .yellow
            }
        }
        
        var body: some View {
            Button(action: { print(action.rawValue) }){
                Label{ Text(action.rawValue.capitalized) } icon: {
                    switch action {
                    case .delete: Image(systemName: "trash")
                    case .archive: Image(systemName: "archivebox.fill")
                    case .share: Image(systemName: "square.and.arrow.up")
                    case .pin: Image(systemName: "pin.fill")
                    }
                }
            }
            .font(.title3[.semibold])
            .tint(tint)
        }
    }
    
    
    struct Cell: View {
        
        @Binding var activeEdge: HorizontalEdge?
        var radius: CGFloat = 16
        var leadingActions: Set<Action> = [.pin]
        var trailingActions: Set<Action> = [.archive, .delete]
        
        @State private var tileColor = Color(hue: .random(in: 0...1), saturation: 0.8, brightness: 1)
        
        @ViewBuilder private func list(_ actions: Set<Action>) -> some View {
            let actions = Action.allCases.filter({ actions.contains($0) })
            
            if !actions.isEmpty {
                ForEach(actions, id: \.self){ action in
                    CellButton(action: action)
                }
            }
        }
        
        var body: some View {
            Button(action: { print("Tap Cell") }){
                HStack(spacing: 12) {
                    ContainerRelativeShape()
                        .fill(tileColor)
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading) {
                        Text("Title")
                            .font(.title2[.semibold])
                        
                        Text("Subtitle")
                            .font(.body)
                            .opacity(0.6)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.title3[.semibold])
                        .opacity(0.6)
                        .layoutDirectionMirror()
                }
                .padding(12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .containerShape(RoundedRectangle(cornerRadius: radius))
            .swipeViews(activeEdge: $activeEdge.animation(.smooth)) {
                list(leadingActions)
            } trailing: {
                list(trailingActions)
            }
            .clipShape(ContainerRelativeShape())
            .background {
                ContainerRelativeShape()
                    .fill(.background)
                    .shadow(color: .black.opacity(0.15), radius: radius, y: radius / 2)
                    .opacity(radius == 0 ? 0 : 1)
            }
            .containerShape(RoundedRectangle(cornerRadius: radius))
        }
    }
    
}


#Preview {
    SwipeActionExamples()
        .previewSize()
}
