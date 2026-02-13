import SwiftUIKit


struct ExampleCell {
    
    
    struct LayoutDirection: View {
        
        typealias Direction = SwiftUI.LayoutDirection
        
        @Binding var value: Direction
        
        var body: some View {
            ExampleInlinePicker(
                data: [.leftToRight, .rightToLeft],
                selection: $value.animation(.smooth),
                content: Label.init
            ){
                Text("Layout Direction")
            }
            .labelStyle(.iconOnly)
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
            ExampleMenuPicker(
                data: [.useSystemDefault, .useTopToBottom, .useBottomToTop],
                selection: $value
            ){
                _Label($0)
            } label: {
                Text("Layout Suggestion")
            }
        }
        
        struct _Label: View {
            
            let suggestion: Suggestion
            
            init(_ suggestion: Suggestion) {
                self.suggestion = suggestion
            }
            
            var body: some View {
                switch suggestion {
                case .useSystemDefault: Text("Use System")
                case .useTopToBottom: Text("Top to Bottom")
                case .useBottomToTop: Text("Bottom to Top")
                }
            }
        }
    }
    
    
    struct ColorScheme: View {
        
        typealias Scheme = SwiftUI.ColorScheme
        
        @Binding var value: Scheme
        
        var body: some View {
            ExampleInlinePicker(
                data: Scheme.allCases,
                selection: $value.animation(.smooth),
                content: { v in
                    Group {
                        switch v {
                        case .light: Label("Light", systemImage: "sun.max")
                        case .dark: Label("Dark", systemImage: "moon.stars.fill")
                        @unknown default: EmptyView()
                        }
                    }
                }
            ){
                Text("Color Scheme")
            }
            .labelStyle(.iconOnly)
        }
    }
    
    
    struct ControlSize: View {
        
        typealias Size = SwiftUIKit.ControlSize
        
        @Binding var value: Size
        
        var body: some View {
            ExampleMenuPicker(data: Size.allCases, selection: $value){ value in
                Text("\(value)".splitCamelCaseFormat)
            } label: {
                Text("Control Size")
            }
        }
    }
    
    
    struct ControlRoundness: View {
        
        @Binding var value: Double
        
        var body: some View {
            ExampleSlider(value: .init($value)){
                Label { Text("Roundness") } icon: {
                    PercentageRoundedRectangle(.vertical, percentage: value)
                        //.trim(from: 0.25, to: 0.75)
                        .strokeBorder(lineWidth: 3)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: 24)
                }
            }
        }
    }
    
    
    struct Alignment: View {
        
        @Binding var value: SwiftUI.Alignment
        
        struct Horizontal: View {
            
            @State private var optionIndex: Int = 1
            
            let options: [HorizontalAlignment] = [.leading, .center, .trailing]
            @Binding var value: HorizontalAlignment
            
            var body: some View {
                ExampleInlinePicker(
                    data: Array(0...2),
                    selection: $optionIndex.animation(.bouncy)
                ){ i in
                    Label(options[i])
                } label: {
                    Text("Horizontal Alignment")
                }
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
                ExampleInlinePicker(
                    data: Array(0...2),
                    selection: $optionIndex.animation(.bouncy)
                ){ i in
                    Label(options[i])
                } label: {
                    Text("Vertical Alignment")
                }
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
            HStack {
                Horizontal(value: $value.horizontal)
                Vertical(value: $value.vertical)
            }
            .labelStyle(.iconOnly)
            .symbolRenderingMode(.hierarchical)
            .symbolVariant(.fill)
        }
        
    }
    
    
    struct HorizontalEdge: View {
        
        typealias Edge = SwiftUI.HorizontalEdge
        
        @Binding var edge: Edge?
        
        var body: some View {
            ExampleInlinePicker(
                data:[Edge.leading, nil, Edge.trailing],
                selection: $edge,
                content: _Label.init
            )
        }
        
        struct _Label : View {
            
            let edge: SwiftUI.HorizontalEdge?
            
            init(_ edge: SwiftUI.HorizontalEdge?) {
                self.edge = edge
            }
            
            var body: some View {
                if let edge {
                   switch edge {
                   case .leading: Label("Leading", systemImage: "inset.filled.leadinghalf.rectangle")
                   case .trailing: Label("Trailing", systemImage: "inset.filled.trailinghalf.rectangle")
                   }
                } else {
                    Label("None", systemImage: "rectangle.slash")
                }
            }
            
        }
    }
    
    
    struct Axis: View {
        
        @Binding var axis: SwiftUI.Axis
        
        var body: some View {
            ExampleInlinePicker(data:  [.horizontal, .vertical], selection: $axis){ axis in
                switch axis {
                case .horizontal: Label("Horizontal", systemImage: "arrow.left.and.right")
                case .vertical: Label("Vertical", systemImage: "arrow.up.and.down")
                }
            }
        }
    }
    
    struct Anchor: View {
        
        @Binding var anchor: UnitPoint
        
        var body: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Anchor")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    VStack(spacing: 5) {
                        LabeledContent{
                            Text(anchor.x, format: .increment(0.01))
                        } label: {
                            Text("X Axis")
                                .fontWeight(.bold)
                                .opacity(0.7)
                        }
                        .padding(4).padding(.horizontal, 4)
                        .background{
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.black.opacity(0.2))
                        }
                        
                        LabeledContent{
                            Text(anchor.y, format: .increment(0.01))
                        } label: {
                            Text("Y Axis")
                                .fontWeight(.bold)
                                .opacity(0.7)
                        }
                        .padding(4).padding(.horizontal, 4)
                        .background{
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.black.opacity(0.2))
                        }
                    }
                    .font(.exampleParameterValue)
                    .padding(5)
                }

                ExampleControl.Anchor(value: $anchor)
                    .frame(width: 130, height: 130)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
}


extension View {
    
    func exampleParameterCell() -> some View {
        containerShape(RoundedRectangle(cornerRadius: 25))
            .padding(.cellPadding)
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
    
    static let cellPadding = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
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
