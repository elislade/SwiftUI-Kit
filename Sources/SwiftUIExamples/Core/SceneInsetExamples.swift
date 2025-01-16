import SwiftUIKit


struct SceneInsetExamples: View {
    
    @State private var disableInsetReading: Bool = false
    @State private var insets: EdgeInsets = .init()
    
    var body: some View {
        ExampleView(title: "Scene Inset"){
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(0..<100) { i in
                        Color(hue: Double(i) / 100, saturation: 1, brightness: 1)
                            .frame(height: 60)
                            .paddingSubtractingSafeArea(i.isMultiple(of: 3) ? .horizontal : [])
                    }
                }
            }
            .safeAreaFromSceneInset()
            .sceneInset(insets)
            .disableInsetReading(disableInsetReading)
        } parameters: {
            Toggle(isOn: $disableInsetReading){
                Text("Disable Inset Reading")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Horizontal Inset")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Group {
                        Text(insets.leading, format: .increment(0.1))
                        Text(insets.trailing, format: .increment(0.1))
                    }
                    .font(.exampleParameterValue)
                }
                
                HStack {
                    Slider(value: $insets.leading, in: 0...80)
                    Slider(value: $insets.trailing, in: 0...80)
                }
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Vertical Inset")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Group {
                        Text(insets.top, format: .increment(0.1))
                        Text(insets.bottom, format: .increment(0.1))
                    }
                    .font(.exampleParameterValue)
                }
                
                HStack {
                    Slider(value: $insets.top, in: 0...80)
                    Slider(value: $insets.bottom, in: 0...80)
                }
            }
            .exampleParameterCell()
        }
    }
    
}


#Preview {
    SceneInsetExamples()
        .previewSize()
}
