import SwiftUIKit


struct ExampleCell {
    
    
    struct LayoutDirection: View {
        
        typealias Direction = SwiftUI.LayoutDirection
        
        @Binding var value: Direction
        
        var body: some View {
            HStack {
                Text("Layout Direction")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                
                SegmentedPicker(
                    selection: $value.animation(.smooth),
                    items: [.leftToRight, .rightToLeft]
                ){
                    Label($0)
                }
                .labelStyle(.iconOnly)
                .frame(width: 90)
                .fontWeight(.bold)
            }
            .exampleParameterCell()
        }
        
        struct Label: View {
            
            let dir: SwiftUI.LayoutDirection
            
            init(_ dir:  SwiftUI.LayoutDirection) {
                self.dir = dir
            }
            
            var body: some View {
                switch dir {
                case .leftToRight:
                    SwiftUI.Label("Left to Right", systemImage: "arrow.right.to.line")
                case .rightToLeft:
                    SwiftUI.Label("Right to Left", systemImage: "arrow.left.to.line")
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
    
    
    struct LayoutDirectionSuggestion: View {
        
        typealias Suggestion = SwiftUIKit.LayoutDirectionSuggestion
        
        @Binding var value: Suggestion
        
        var body: some View {
            HStack {
                Text("Layout Suggestion")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $value){
                    Text("Use System").tag(Suggestion.useSystemDefault)
                    Text("Top to Bottom").tag(Suggestion.useTopToBottom)
                    Text("Bottom to Top").tag(Suggestion.useBottomToTop)
                }
            }
            .exampleParameterCell()
        }
    }
    
    
    struct ColorScheme: View {
        
        typealias Scheme = SwiftUI.ColorScheme
        
        @Binding var value: Scheme
        
        var body: some View {
            HStack {
                Text("Color Scheme")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                SegmentedPicker(
                    selection: $value.animation(.smooth),
                    items: Scheme.allCases
                ){
                    switch $0 {
                    case .light: Text("Light")
                    case .dark: Text("Dark")
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: 120)
                .controlRoundness(1)
            }
            .exampleParameterCell()
        }
    }
    
    
    struct ControlSize: View {
        
        typealias Size = SwiftUIKit.ControlSize
        
        @Binding var value: Size
        
        var body: some View {
            HStack {
                Text("Control Size")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $value){
                    ForEach(Size.allCases, id: \.self){
                        Text("\($0)".splitCamelCaseFormat).tag($0)
                    }
                }
            }
            .exampleParameterCell()
        }
    }
    
    
    struct ControlRoundness: View {
        
        @Binding var value: Double
        
        var body: some View {
            VStack {
                HStack {
                    Text("Control Roundness")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(value, format: .increment(0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $value, in: 0...1)
            }
            .exampleParameterCell()
        }
    }
    
    
    struct Alignment: View {
        
        @Binding var value: SwiftUI.Alignment
        
        struct Horizontal: View {
            
            @State private var optionIndex: Int = 1
            
            let options: [HorizontalAlignment] = [.leading, .center, .trailing]
            @Binding var value: HorizontalAlignment
            
            var body: some View {
                HStack {
                    Text("Horizontal Alignment")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    SegmentedPicker(selection: $optionIndex.animation(.bouncy), items: Array(0...2)){ i in
                        Label(options[i])
                            .layoutDirectionMirror()
                    }
                    .frame(width: 120)
                    .labelStyle(.iconOnly)
                    .symbolVariant(.fill)
                    .symbolRenderingMode(.hierarchical)
                    .imageScale(.small)
                }
                .exampleParameterCell()
                .onChangePolyfill(of: optionIndex){
                    value = options[optionIndex]
                }
            }
            
            struct Label: View {
                
                let alignment: HorizontalAlignment
                
                init(_ alignment: HorizontalAlignment) {
                    self.alignment = alignment
                }
                
                var body: some View {
                    if alignment == .leading {
                        SwiftUI.Label("Leading", systemImage: "align.horizontal.left")
                    } else if alignment == .center {
                        SwiftUI.Label("Center", systemImage: "align.horizontal.center")
                    } else if alignment == .trailing {
                        SwiftUI.Label("Trailing", systemImage: "align.horizontal.right")
                    }
                }
            }
            
        }
        
        struct Vertical: View {
            
            @State private var optionIndex: Int = 1
            
            let options: [VerticalAlignment] = [.top, .center, .bottom]
            @Binding var value: VerticalAlignment
            
            var body: some View {
                HStack {
                    Text("Vertical Alignment")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    SegmentedPicker(selection: $optionIndex.animation(.bouncy), items: Array(0...2)){ i in
                        Label(options[i])
                    }
                    .frame(width: 120)
                    .labelStyle(.iconOnly)
                    .symbolVariant(.fill)
                    .symbolRenderingMode(.hierarchical)
                    .imageScale(.small)
                }
                .exampleParameterCell()
                .onChangePolyfill(of: optionIndex){
                    value = options[optionIndex]
                }
            }
            
            struct Label: View {
                
                let alignment: VerticalAlignment
                
                init(_ alignment: VerticalAlignment) {
                    self.alignment = alignment
                }
                
                var body: some View {
                    if alignment == .top {
                        SwiftUI.Label("Top", systemImage: "align.vertical.top")
                    } else if alignment == .center {
                        SwiftUI.Label("Center", systemImage: "align.vertical.center")
                    } else if alignment == .bottom {
                        SwiftUI.Label("Bottom", systemImage: "align.vertical.bottom")
                    }
                }
            }
        }
        
        var body: some View {
            Horizontal(value: $value.horizontal)
            Vertical(value: $value.vertical)
        }
        
    }
    
    
    struct HorizontalEdge: View {
        
        typealias Edge = SwiftUI.HorizontalEdge
        
        @Binding var edge: Edge?
        
        var body: some View {
            SegmentedPicker(selection: $edge, items: [Edge.leading, nil, Edge.trailing]){ edge in
                if let edge {
                   switch edge {
                   case .leading: Text("Leading")
                   case .trailing: Text("Trailing")
                }
                } else {
                    Text("None")
                }
            }
            .font(.caption)
        }
    }
    
    
    struct Axis: View {
        
        @Binding var axis: SwiftUI.Axis
        
        var body: some View {
            HStack {
                Text("Axis")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                SegmentedPicker(selection: $axis, items: [.horizontal, .vertical]){ axis in
                    switch axis {
                    case .horizontal: Label("Horizontal", systemImage: "arrow.left.and.right")
                    case .vertical: Label("Vertical", systemImage: "arrow.up.and.down")
                    }
                }
                .font(.caption)
                .labelStyle(.iconOnly)
                .frame(width: 100)
            }
        }
    }
    
}


extension View {
    
    func exampleParameterCell() -> some View {
        padding(.cellPadding)
            .toggleStyle(.swiftUIKitSwitch)
            .labeledContentStyle(.exampleCell)
            .fixedSize(horizontal: false, vertical: true)
            .geometryGroupIfAvailable()
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .controlRoundness(1)
            .contentTransitionNumericText()
    }
    
}


extension EdgeInsets {
    
    static let cellPadding = EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
}


struct ExampleCellLabeledContentStyle: LabeledContentStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0){
            configuration.label
            Spacer(minLength: 12)
            configuration.content
        }
    }
    
}

extension LabeledContentStyle where Self == ExampleCellLabeledContentStyle {
    
    static var exampleCell: Self { .init() }
    
}
