import SwiftUIKit


struct SwipeActionExamples: View {
    
    enum Action: String, CaseIterable {
        case delete
        case archive
        case share
        case pin
        
        var image: Image {
            switch self {
            case .delete: Image(systemName: "trash")
            case .archive: Image(systemName: "archivebox.fill")
            case .share: Image(systemName: "square.and.arrow.up")
            case .pin: Image(systemName: "pin.fill")
            }
        }
        
        var color: Color {
            switch self {
            case .delete: .red
            case .archive: .orange
            case .share: .blue
            case .pin: .yellow
            }
        }
    }
    
    @State private var activeEdges: HorizontalEdge.Set = .leading
    @State private var layoutDirection: LayoutDirection = .leftToRight
    @State private var cellRadius: Double = 16
    @State private var leadingActions: [Action] = [.pin]
    @State private var trailingActions: [Action] = [.archive, .delete]
    
    private func activeEdges(at index: Int) -> Binding<HorizontalEdge.Set> {
        if index == 0 {
            return $activeEdges
        } else {
            return .constant([])
        }
    }
    
    private func binding(for set: HorizontalEdge.Set) -> Binding<Bool> {
        .init(
            get: { activeEdges == set },
            set: {
                if $0 {
                    activeEdges = set
                } else {
                    activeEdges = []
                }
            }
        )
    }
    
    private func view(for action: Action) -> some View {
        Button(action: {}){
            Label{
                Text(action.rawValue.capitalized)
            } icon: {
                action.image
            }
        }
        .font(.title3[.semibold])
        .tint(action.color)
    }
    
    private func binding(for action: Action, in actions: Binding<[Action]>) -> Binding<Bool> {
        .init(
            get: { actions.wrappedValue.contains(action) },
            set: {
                if $0 {
                    actions.wrappedValue.append(action)
                } else {
                    actions.wrappedValue.removeAll(where: { $0 == action })
                }
            }
        )
    }
    
    var body: some View {
        ExampleView(title: "Swipe Actions"){
            ScrollView {
                VStack(spacing: cellRadius == 0 ? 0 : 16) {
                    ForEach(0...2){ i in
                        Cell()
                            .swipeViews(activeEdge: activeEdges(at: i)) {
                                let actions = Action.allCases.filter({ leadingActions.contains($0) })
                                if !actions.isEmpty {
                                    ForEach(actions, id: \.self){ action in
                                        view(for: action)
                                    }
                                }
                            } trailing: {
                                let actions = Action.allCases.filter({ trailingActions.contains($0) })
                                
                                if !actions.isEmpty {
                                    ForEach(actions, id: \.self){
                                        view(for: $0)
                                    }
                                }
                            }
                            .clipShape(ContainerRelativeShape())
                            .background {
                                ContainerRelativeShape()
                                    .fill(.background)
                                    .shadow(color: .black.opacity(0.15), radius: cellRadius, y: cellRadius / 2)
                                    .opacity(cellRadius == 0 ? 0 : 1)
                            }
                            .containerShape(RoundedRectangle(cornerRadius: cellRadius))
                        
                        if cellRadius == 0 {
                            Divider()
                        }
                    }
                }
                .padding(cellRadius == 0 ? 0 : 16)
                .labelStyle(.iconOnly)
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
                    .padding()
                    
                    Divider()
                    
                    ExampleCell.LayoutDirection(value: $layoutDirection)
                    
                    Divider()
                }
            }
            
            Divider()
            
            ExampleSection("Leading Views", isExpanded: true){
                VStack(spacing: 0){
                    Toggle(isOn: binding(for: .leading)){
                       Text("First Active")
                            .font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    ForEach(Action.allCases, id: \.self){ action in
                        Toggle(isOn: binding(for: action, in: $leadingActions)){
                            view(for: action)
                        }
                        .padding()
                        
                        Divider()
                    }
                }
            }
            
            Divider()
            
            ExampleSection("Trailing Views", isExpanded: true){
                VStack(spacing: 0){
                    Toggle(isOn: binding(for: .trailing)){
                       Text("First Active")
                            .font(.exampleParameterTitle)
                    }
                    .padding()
                    
                    Divider()
                    
                    ForEach(Action.allCases, id: \.self){ action in
                        Toggle(isOn: binding(for: action, in: $trailingActions)){
                            view(for: action)
                        }
                        .padding()
                        
                        Divider()
                    }
                }
            }
        }
    }
    
    
    struct Cell: View {
        
        var body: some View {
            Button(action: {}){
                HStack(spacing: 12) {
                    ContainerRelativeShape()
                        .fill(Color.random)
                        .frame(width: 60, height: 60)
                    
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
        }
    }
    
}


#Preview {
    SwipeActionExamples()
}
