import SwiftUIKit


struct ExampleCell {
    
    
    struct LayoutDirection: View {
        
        @Binding var value: SwiftUI.LayoutDirection
        
        var body: some View {
            HStack {
                Text("Layout Direction")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $value){
                    Text("Left to Right").tag(SwiftUI.LayoutDirection.leftToRight)
                    Text("Right to Left").tag(SwiftUI.LayoutDirection.rightToLeft)
                }
            }
            .exampleParameterCell()
        }
    }
    
    
    struct LayoutDirectionSuggestion: View {
        
        @Binding var value: SwiftUIKit.LayoutDirectionSuggestion
        
        var body: some View {
            HStack {
                Text("Layout Suggestion")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $value){
                    Text("Use System").tag(SwiftUIKit.LayoutDirectionSuggestion.useSystemDefault)
                    Text("Top to Bottom").tag(SwiftUIKit.LayoutDirectionSuggestion.useTopToBottom)
                    Text("Bottom to Top").tag(SwiftUIKit.LayoutDirectionSuggestion.useBottomToTop)
                }
            }
            .exampleParameterCell()
        }
    }
    
    
    struct ColorScheme: View {
        
        @Binding var value: SwiftUIKit.ColorScheme
        
        var body: some View {
            HStack {
                Text("Color Scheme")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                SegmentedPicker(selection: $value.animation(.smooth), items: SwiftUIKit.ColorScheme.allCases){
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
        
        @Binding var value: SwiftUIKit.ControlSize
        
        var body: some View {
            HStack {
                Text("Control Size")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $value){
                    ForEach(SwiftUIKit.ControlSize.allCases, id: \.self){
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
                    
                    Text(value, format: .number.rounded(increment: 0.1))
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
    
    
}


extension View {
    
    func exampleParameterCell() -> some View {
        Group {
        #if os(macOS)
            padding(.horizontal).padding(.vertical, 10)
        #else
            padding()
        #endif
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
        .geometryGroupPolyfill()
        .lineLimit(2)
        .minimumScaleFactor(0.5)
        .controlRoundness(1)
    }
    
}
