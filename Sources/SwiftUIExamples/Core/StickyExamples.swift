import SwiftUIKit


struct StickyExamples  {
    
    static let numberOfItems: Int = 40
    
    struct Sticky: View {
        
        @State private var stickyItems: [Int] = [3, 5]
        @State private var axis: Axis? = .vertical
        @State private var grouping: StickyGrouping = .stacked
        @State private var inset: CGFloat = 0
        
        var body: some View {
            ExampleView(title: "Sticky"){
                if let axis {
                    ScrollSticky(axis: axis, inset: inset, stickyItems: $stickyItems)
                        .stickyContext(grouping: grouping)
                        .id(axis)
                } else {
                    BothSticky(stickyItems: $stickyItems)
                        .stickyContext(grouping: grouping)
                }
            } parameters: {
                HStack {
                    Text("Axis")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Picker("", selection: $axis){
                        Text("Both").tag(Optional<Axis>(nil))
                        Text("Horizontal").tag(Optional<Axis>(.horizontal))
                        Text("Vertical").tag(Optional<Axis>(.vertical))
                    }
                }
                .padding()
                
                Divider()
                
                HStack {
                    Text("Grouping")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Picker("", selection: $grouping){
                        ForEach(StickyGrouping.allCases, id: \.self){
                            Text("\($0)".capitalized).tag($0)
                        }
                    }
                }
                .padding()
                
                Divider()
                
                VStack {
                    HStack {
                        Text("Edge Inset")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(inset, format: .number.rounded(increment: 0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $inset, in: 0...20)
                }
                .padding()
                
                Divider()
            }
        }
    }
    
    
    struct Cell: View {
        
        var axis: Axis = .horizontal
        var isSticky: Bool = false
        var isSticking: Bool = false
        
        var body: some View {
            AxisStack(axis, spacing: 0){
                Text("Item")
                Spacer(minLength: 0)
                if isSticky {
                    Text("🍯")
                        .transitions(.scale, .opacity)
                }
            }
            .padding(20)
            .font(.title2)
            .background{
                if isSticky {
                    Rectangle()
                        .fill(.background)
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
                        
                        Button(action: { action(for: i) }){
                            Cell(
                                axis: .vertical,
                                isSticky: stickyItems.contains(i),
                                isSticking: isSticking
                            )
                            .frame(width: size, height: size)
                        }
                        .buttonStyle(.tintStyle)
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
                .onChange(of: stickyItems.last){ item in
                    isSticking = []
                    withAnimation(.fastSpring){
                        proxy.scrollTo(item, anchor: .center)
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
                            
                            Button(action: { action(for: i) }){
                                Cell(
                                    axis: axis.inverse,
                                    isSticky: stickyItems.contains(i),
                                    isSticking: isSticking
                                )
                            }
                            .buttonStyle(.tintStyle)
                            .id(i)
                            .sticky(edges: stickyItems.contains(i) ? .init(axis) : [], inset: inset){ state in
                                if state.isSticking {
                                    self.isSticking.insert(i)
                                } else {
                                    self.isSticking.remove(i)
                                }
                            }
                            
                            Divider()
                        }
                    }
                }
                .onChange(of: stickyItems.last){ item in
                    isSticking = []
                    withAnimation(.fastSpring){
                        proxy.scrollTo(item, anchor: .center)
                    }
                }
            }
        }
    }

    
    struct CategoryMask: View {
        
        var body: some View {
            VStack {
                ScrollView{
                    VStack(spacing: 16) {
                        Rectangle()
                            .frame(height: 100)
                        
                        HStack {
                            Spacer()
                            
                            Rectangle()
                                .aspectRatio(2, contentMode: .fit)
                                .sticky(edges: .top, categoryMask: .span1)
                            
                            Spacer()
                            
                            Rectangle()
                                .aspectRatio(0.6, contentMode: .fit)
                                .sticky(edges: .top, inset: 10, categoryMask: .span2)
                            
                            Spacer()
                        }
                        .opacity(0.8)
                        
                        Rectangle()
                            .frame(height: 100)
                            .opacity(0.6)
                        
                        HStack {
                            Spacer()
                            
                            Rectangle()
                                .aspectRatio(2, contentMode: .fit)
                                .sticky(edges: .top, categoryMask: .span1)
                            
                            Spacer()
                            
                            Rectangle()
                                .aspectRatio(0.6, contentMode: .fit)
                                .sticky(edges: .top, inset: 40, categoryMask: .span2)
                            
                            Spacer()
                        }
                        .foregroundStyle(Color(white: 0.6))
                        
                        Rectangle()
                            .opacity(0.2)
                            .frame(height: 800)
                            .sticky(edges: .top, categoryMask: .fullSpan)
                        
                        Rectangle()
                            .opacity(0)
                            .frame(height: 1)
                            .sticky(edges: .top, categoryMask: .fullSpan)
                        
                    }
                }
                .stickyContext()
                .background{ Color.secondary.opacity(0.2) }
                .overlay{
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder()
                        .opacity(0.2)
                }
                .clipShape(RoundedRectangle(cornerRadius: 30))
                
                ExampleTitle("Sticky Category Mask")
            }
            .padding()
        }
    }
    
}


#Preview("Sticky Example") {
    StickyExamples.Sticky()
        .previewSize()
}

#Preview("Sticky Category Mask") {
    StickyExamples.CategoryMask()
        .previewSize()
}

fileprivate extension StickyCategoryMask {
    
    static let span1 = StickyCategoryMask(rawValue: 1 << 2)
    static let span2 = StickyCategoryMask(rawValue: 1 << 3)
    static let fullSpan: StickyCategoryMask = [span1, span2]
    
}
