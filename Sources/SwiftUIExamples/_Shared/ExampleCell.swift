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
                
                Picker("", selection: $value){
                    Text("Left to Right").tag(Direction.leftToRight)
                    Text("Right to Left").tag(Direction.rightToLeft)
                }
            }
            .exampleParameterCell()
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
        
        @State private var horzOptionIndex: Int = 1
        @State private var vertOptionIndex: Int = 1
        
        let horizontalOptions: [HorizontalAlignment] = [.leading, .center, .trailing]
        let verticalOptions: [VerticalAlignment] = [.top, .center, .bottom]
        
        
        var body: some View {
            HStack {
                Text("Horizontal Alignment")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $horzOptionIndex){
                    Text("Leading").tag(0)
                    Text("Center").tag(1)
                    Text("Trailing").tag(2)
                }
            }
            .exampleParameterCell()
            .onChangePolyfill(of: horzOptionIndex){
                value.horizontal = horizontalOptions[horzOptionIndex]
            }
            
            HStack {
                Text("Vertical Alignment")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $vertOptionIndex){
                    Text("Top").tag(0)
                    Text("Center").tag(1)
                    Text("Bottom").tag(2)
                }
            }
            .exampleParameterCell()
            .onChangePolyfill(of: vertOptionIndex){
                value.vertical = verticalOptions[vertOptionIndex]
            }
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
    
}


extension View {
    
    func exampleParameterCell() -> some View {
        padding(.cellPadding)
            .overlay(alignment: .bottom) {
                Divider()
            }
            .toggleStyle(.swiftUIKitSwitch)
            .fixedSize(horizontal: false, vertical: true)
            .geometryGroupPolyfill()
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .controlRoundness(1)
            .contentTransitionNumericText()
    }
    
}


extension EdgeInsets {
    
    static let cellPadding = EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
}
