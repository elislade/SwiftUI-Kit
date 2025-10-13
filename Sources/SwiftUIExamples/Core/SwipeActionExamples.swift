import SwiftUIKit


public struct SwipeActionExamples: View {
    
    enum Action: UInt8, CaseIterable, Identifiable {
        var id: RawValue { rawValue }
        
        case delete
        case archive
        case share
        case pin
    }
    
    struct Element: Identifiable, Equatable {
        let id = UUID()
        let createdOn = Date()
        let color: Color
        var isArchived: Bool = .random()
        var isPinned: Bool = false
    }
    
    @State private var cells: [Element] = (0..<3).map{ _ in .init(color: .random) }
    @State private var cellRadius: Double = 16
    @State private var swipeState: [UUID: HorizontalEdge] = [:]
    @State private var actionState: [Action: HorizontalEdge] = [
        .pin : .leading, .archive : .trailing, .delete : .trailing
    ]
    @State private var invalidation: SwipeActionInvalidation = [.onOpen, .onMove]
    @State private var layoutDirection: LayoutDirection = .leftToRight
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Swipe Actions"){
            Content(
                cells: $cells,
                swipeState: $swipeState,
                cellRadius: cellRadius,
                actionState: actionState
            )
            .labelStyle(.layoutSuggestable)
            .layoutDirectionSuggestion(.useTopToBottom)
            .environment(\.layoutDirection, layoutDirection)
            .swipeActionInvalidation(invalidation)
            .indirectScrollGroup()
        } parameters: {
            ExampleSection("Invalidation", isExpanded: true){
                Toggle(isOn: Binding($invalidation, subset: .onMove)){
                    Text("On Move")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
                
                Toggle(isOn: Binding($invalidation, subset: .onOpen)){
                    Text("On Open")
                        .font(.exampleParameterTitle)
                }
                .exampleParameterCell()
            }
            
            ExampleSection("Cell Style", isExpanded: true){
                VStack {
                    HStack {
                        Text("Radius")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(cellRadius, format: .number.rounded(increment: 0.1))
                            .monospacedDigit()
                    }
                    
                    Slider(value: $cellRadius, in: 0...36)
                }
                .exampleParameterCell()
                
                ExampleCell.LayoutDirection(value: $layoutDirection)
            }
            
            ExampleSection("Active Edges", isExpanded: true){
                ForEach(cells){ cell in
                    let index = cells.firstIndex(of: cell)!
                    HStack {
                        Text("Element \(index + 1)")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        ExampleCell.HorizontalEdge(edge: $swipeState[cell.id].animation(.smooth))
                            .frame(maxWidth: 180)
                    }
                    .exampleParameterCell()
                }
            }
            
            ExampleSection("Action Visibility", isExpanded: true){
                ForEach(Action.allCases, id: \.self){ action in
                    HStack {
                        ActionLabel(action)
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        ExampleCell.HorizontalEdge(edge: $actionState[action].animation(.smooth))
                            .frame(maxWidth: 180)
                    }
                    .exampleParameterCell()
                }
            }
        }
    }
    
    
    struct Content: View {
        
        @Binding var cells: [Element]
        @Binding var swipeState: [UUID: HorizontalEdge]
        
        var cellRadius: Double = 16
        let actionState: [Action: HorizontalEdge]
        
        var body: some View {
            ScrollView {
                ScrollBody(
                    cells: $cells.animation(.bouncy),
                    swipeState: $swipeState,
                    cellRadius: cellRadius,
                    actionState: actionState
                )
            }
            .safeAreaInset(edge: .top, spacing: 0){
                HStack {
                    Text("Elements")
                    
                    Spacer()
                    
                    Button{
                        cells.append(.init(color: .random))
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.tinted)
                    .labelStyle(.iconOnly)
                    .symbolRenderingMode(.hierarchical)
                }
                .font(.largeTitle[.semibold])
                .padding()
                .background(alignment: .bottom){
                    VisualEffectView()
                        .ignoresSafeArea()
                    
                    ExampleBackground()
                        .ignoresSafeArea()
                        .opacity(0.6)
                    
                    Divider()
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .ignoresSafeArea()
                }
            }
        }
        
        struct ScrollBody: View {
            
            @Binding var cells: [Element]
            @Binding var swipeState: [UUID: HorizontalEdge]
            var cellRadius: Double = 10
            let actionState: [Action: HorizontalEdge]
            
            private func sortValue(for element: Element) -> Int {
                let index = cells.firstIndex(of: element)!
                
                if element.isPinned {
                    return (-cells.count) + index
                } else {
                    return index
                }
            }
            
            var body: some View {
                let elements = $cells.sorted(by: {
                    sortValue(for: $0.wrappedValue) < sortValue(for: $1.wrappedValue)
                })
                VStack(spacing: cellRadius == 0 ? 0 : 16){
                    ForEach(elements){ cell in
                        Cell(
                            element: cell,
                            activeEdge: $swipeState[cell.id],
                            radius: cellRadius,
                            actionState: actionState
                        ){
                            cells.removeAll(where: { $0.id == cell.id })
                        }
                        .overlay(alignment: .bottom){
                            if cellRadius == 0 {
                                Divider()
                                    .transition(
                                        .asymmetric(
                                            insertion: .offset([400,0]).animation(.smooth.delay(Double(0) / 8)),
                                            removal: .identity
                                        )
                                    )
                            }
                        }
                        .transition((.scale(0.5) + .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .geometryGroupPolyfill()
                .animation(.bouncy, value: cellRadius == 0)
                .padding(cellRadius == 0 ? 0 : 16)
                .animation(.smooth, value: elements.map(\.wrappedValue))
            }
        }
        
    }
    
    
    struct ActionLabel: View {
        
        let action: Action
        let undo: Bool
        
        init(_ action: Action, undo: Bool = false) {
            self.action = action
            self.undo = undo
        }
        
        var body: some View {
            ZStack {
                switch action {
                case .delete:
                    Label{ Text("Delete") } icon: {
                        Image(systemName: "trash.fill")
                            .environmentStyled()
                    }
                case .archive:
                    Label{ Text(undo ? "Unarchive" : "Archive") } icon: {
                        Image(systemName: "archivebox.fill")
                            .environmentStyled()
                    }
                    .symbolVariant(undo ? .slash : .none)
                case .share:
                    Label{ Text("Share") } icon: {
                        Image(systemName: "square.and.arrow.up")
                            .environmentStyled()
                    }
                case .pin:
                    Label{ Text(undo ? "Unpin" : "Pin") } icon: {
                        Image(systemName: undo ? "pin.slash.fill" : "pin.fill")
                            .environmentStyled()
                    }
                }
            }
        }
        
    }
    
    
    struct Cell: View {
        
        @State private var tapCount = 0
        @State private var showShare = false
        
        @Binding var element: Element
        @Binding var activeEdge: HorizontalEdge?
        
        var radius: CGFloat = 16
        let actionState: [Action: HorizontalEdge]
        var delete: () -> Void = {}
        
        private func perform(action: Action) {
            switch action {
            case .delete: delete()
            case .archive: element.isArchived.toggle()
            case .share: showShare.toggle()
            case .pin: element.isPinned.toggle()
            }
        }
        
        private func shouldUndo(action: Action) -> Bool {
            switch action {
            case .delete: false
            case .archive: element.isArchived
            case .share: false
            case .pin: element.isPinned
            }
        }
        
        private func list(_ edge: HorizontalEdge) -> some View {
            let actions = Action.allCases.filter({ actionState[$0] == edge })
            return ForEach(actions){ action in
                let index = Double(actions.firstIndex(of: action)!)
                Button(role: action == .delete ? .destructive : nil){
                    perform(action: action)
                } label: {
                    ActionLabel(action, undo: shouldUndo(action: action))
                        .font(.caption)
                        .tint(Color(action))
                }
                .tint(Color(action))
                .transition(
                    (
                        .rotation(angle: .degrees(radius * 2)) +
                        (.scale + .opacity).animation(.bouncy.delay(0.05))
                    ).animation(.bouncy.delay(index / 8))
                )
            }
            .actionTriggerBehaviour(.afterDelay(.milliseconds(100)))
        }
        
        var body: some View {
            Button{ tapCount += 1 } label: {
                Content(
                    element: element,
                    tapCount: tapCount
                )
                .tint(element.color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(10)
                .contentShape(ContainerRelativeShape())
            }
            .buttonStyle(.plain)
            .containerShape(RoundedRectangle(cornerRadius: radius))
            .background {
                if radius == 0 {
                    ExampleBackground()
                } else {
                    ContainerRelativeShape()
                        .fill(.background)
                        .shadow(color: .black.opacity(0.15), radius: radius, y: radius / 2)
                }
                
                if element.isPinned {
                    ContainerRelativeShape()
                        .fill(.yellow.opacity(0.1))
                }
            }
            .geometryGroupPolyfill()
            .swipeViews(activeEdge: $activeEdge) {
                list(.leading)
                    .imageStyle(.exampleSwipe)
            } trailing: {
                list(.trailing)
                    .imageStyle(.exampleSwipe)
            }
            .containerShape(RoundedRectangle(cornerRadius: radius))
        }
        
        
        struct Content: View {
            
            let element: Element
            let tapCount: Int
            
            var body: some View {
                HStack(spacing: 12) {
                    if element.isPinned {
                        ActionLabel(.pin)
                            .labelStyle(.iconOnly)
                            .imageStyle(.exampleSwipe)
                            .padding(4)
                            .frame(width: 22, height: 22)
                            .background{
                                Circle().fill(Color(.pin))
                            }
                    }
                    
                    ContainerRelativeShape()
                        .fill(.tint)
                        .frame(maxWidth: 50, maxHeight: 50)
                    
                    VStack(alignment: .leading) {
                        Text("Title")
                            .font(.title2[.semibold])
                        
                        Text("Subtitle")
                            .font(.body)
                            .opacity(0.6)
                    }
                    
                    Spacer()
                    
                    Text(tapCount, format: .number)
                        .contentTransitionNumericText()
                        .font(.caption[.semibold])
                        .monospacedDigit()
                        .padding(5)
                        .background(.quaternary, in: .capsule)
                        .animation(.bouncy, value: tapCount)
                    
                    if element.isArchived {
                        ActionLabel(.archive)
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.orange)
                            .transition(.scale)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.title3[.semibold])
                        .opacity(0.6)
                        .layoutDirectionMirror()
                }
                .animation(.bouncy, value: element.isArchived)
                .animation(.bouncy, value: element.isPinned)
            }
        }
        
    }
    
    
}

extension Color {
    
    init(_ action: SwipeActionExamples.Action) {
        switch action {
        case .delete: self = .red
        case .archive: self = .orange
        case .share: self = .blue
        case .pin: self = .yellow
        }
    }
    
}

#Preview {
    SwipeActionExamples()
        .previewSize()
}


struct ExampleSwipeStyle : ImageStyle {
    
    func style(image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            .foregroundStyle(LinearGradient(
                colors: [.white.opacity(0.6), .white.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            ))
            .overlay {
                image
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.black.shadow(.inner(color: .white, radius: 0.5, y: 1)))
                    .blendMode(.overlay)
            }
    }
    
}


extension ImageStyle where Self == ExampleSwipeStyle {
    
    static var exampleSwipe: Self { Self() }
    
}
