import SwiftUIKit


public struct StickyExample: View  {
    
    static let numberOfItems: Int = 40
    
    @State private var stickyItems: [Int] = [3, 5]
    @State private var axis: Axis? = .vertical
    @State private var grouping: StickyGrouping = .stacked
    @State private var inset: Double = 0
    
    public init(){}
    
    public var body: some View {
        ExampleView(title: "Sticky"){
            if let axis {
                ScrollSticky(axis: axis, inset: inset, stickyItems: $stickyItems)
                    .stickyContext()
                    .stickyGrouping(grouping)
                    .id(axis)
            } else {
                BothSticky(stickyItems: $stickyItems)
                    .stickyContext()
                    .stickyGrouping(grouping)
            }
        } parameters: {
            ExampleSection(isExpanded: true){
                ExampleControlGroup {
                    ExampleMenuPicker(
                        data: [nil, Axis.horizontal, .vertical],
                        selection: $axis
                    ){ axis in
                        if let axis {
                            Text("\(axis)".capitalized)
                        } else {
                            Text("Both")
                        }
                    } label: {
                        Text("Axis")
                    }
                    
                    ExampleMenuPicker(
                        data: StickyGrouping.allCases,
                        selection: $grouping
                    ){
                        Text("\($0)".capitalized)
                    } label: {
                        Text("Grouping")
                    }
                }
                
                ExampleSlider(value: .init($inset, in: 0...20)){
                    Text("Edge Inset")
                }
            } label: {
                Text("Parameters")
            }
        }
    }
    
    
    struct Cell: View {
        
        var index: Int = 0
        var axis: Axis = .horizontal
        var isSticky: Bool = false
        var isSticking: Bool = false
        
        var body: some View {
            AxisStack(axis, spacing: 0){
                Text("Item \(index)")
                Spacer(minLength: 0)
                if isSticky {
                    Text("🍯")
                        .transition(.scale + .opacity)
                }
            }
            .padding()
            .font(.title2)
            .background{
                if isSticky {
                    Rectangle()
                        .fill(.background)
                        .ignoresSafeArea()
                        .opacity(isSticking ? 1 : 0)
                }
            }
        }
        
    }
    
    
    struct BothSticky: View {
        
        @Binding var stickyItems: [Int]
        @State private var isSticking: Set<Int> = []
        
        private let size: CGFloat = 90
        
        private func action(for i: Int) {
            if stickyItems.contains(i){
                stickyItems.removeAll(where: { $0 == i })
            } else {
                stickyItems.append(i)
            }
        }
        
        var body: some View {
            ScrollViewReader{ proxy in
                ScrollView([.horizontal, .vertical]){
                    AlignmentGuideGrid(0..<numberOfItems, spacing: 1, columns: 6){ i in
                        let isSticking = self.isSticking.contains(i)
                        
                        Button{ action(for: i) } label: {
                            Cell(
                                index: i,
                                axis: .vertical,
                                isSticky: stickyItems.contains(i),
                                isSticking: isSticking
                            )
                            .frame(width: size, height: size)
                        }
                        .buttonStyle(.tinted)
                        .id(i)
                        .sticky(edges: stickyItems.contains(i) ? .all : []){ state in
                            if state.isSticking {
                                self.isSticking.insert(i)
                            } else {
                                self.isSticking.remove(i)
                            }
                        }
                    }
                    .lineLimit(1)
                }
                .onChangePolyfill(of: stickyItems.last){
                    isSticking = []
                    withAnimation(.fastSpring){
                        proxy.scrollTo(stickyItems.last, anchor: .center)
                    }
                }
            }
        }
    }
    
    
    struct ScrollSticky: View {
        
        let axis: Axis
        var inset: CGFloat = 0
        @Binding var stickyItems: [Int]
        @State private var isSticking: Set<Int> = []
        
        private func action(for i: Int) {
            if stickyItems.contains(i){
                stickyItems.removeAll(where: { $0 == i })
            } else {
                stickyItems.append(i)
            }
        }
        
        var body: some View {
            ScrollViewReader{ proxy in
                ScrollView(axis.asSet){
                    AxisStack(axis, spacing: 0){
                        ForEach(0..<numberOfItems, id: \.self){ i in
                            let isSticking = self.isSticking.contains(i)
                            
                            Button{ action(for: i) } label: {
                                Cell(
                                    index: i,
                                    axis: axis.inverse,
                                    isSticky: stickyItems.contains(i),
                                    isSticking: isSticking
                                )
                            }
                            .buttonStyle(.tinted)
                            .id(i)
                            .overlay(alignment: .bottom) {
                                Divider()
                                    .ignoresSafeArea()
                            }
                            .sticky(edges: stickyItems.contains(i) ? .init(axis) : [], inset: inset){ state in
                                if state.isSticking {
                                    self.isSticking.insert(i)
                                } else {
                                    self.isSticking.remove(i)
                                }
                            }
                        }
                    }
                }
                .onChangePolyfill(of: stickyItems.last){
                    isSticking = []
                    withAnimation(.fastSpring){
                        proxy.scrollTo(stickyItems.last, anchor: .center)
                    }
                }
            }
        }
        
    }
    
}


#Preview("Sticky Example") {
    StickyExample()
        .previewSize()
}
