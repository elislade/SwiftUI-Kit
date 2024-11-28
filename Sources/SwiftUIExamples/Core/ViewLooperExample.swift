import SwiftUIKit


struct ViewLooperExample: View {
    
    @State private var axis: Axis = .horizontal
    @State private var feather = true
    @State private var durationSpan: TimeSpanMode = .relative
    @State private var duration: TimeInterval = 30
    @State private var wait: TimeInterval = 3
    
    enum TimeSpanMode {
        case relative
        case absolute
        
        var isRelative: Bool {
            self == .relative
        }
    }
    
    private var durationEnum: TimeSpan {
        switch durationSpan {
        case .relative: .relative(duration)
        case .absolute: .absolute(duration)
        }
    }
    
    var body: some View {
        ExampleView(title: "View Looper"){
            ViewLooper(
                axis,
                duration: durationEnum,
                wait: wait,
                featherMask: feather
            ) {
                Text("Supercalifragilisticexpialidocious".capitalized)
                    .font(.system(size: 8, design: .serif).bold().italic())
                    .lineLimit(1)
                    .padding(.horizontal)
            }
        } parameters: {
            HStack {
                Text("Axis")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $axis){
                    Text("Horizontal").tag(Axis.horizontal)
                    Text("Vertical").tag(Axis.vertical)
                }
            }
            .padding()
            
            Divider()
            
            VStack {
                HStack {
                    Text("Duration")
                        .font(.exampleParameterTitle)
                    
                    Text(duration, format: .number.rounded(increment: 0.1))
                        .font(.exampleParameterValue)
                    
                    Spacer()
                    
                    Picker("", selection: $durationSpan){
                        Text("Relative").tag(TimeSpanMode.relative)
                        Text("Absolute").tag(TimeSpanMode.absolute)
                    }
                }
                
                Slider(
                    value: $duration,
                    in: durationSpan.isRelative ? 1...100 : 0.1...20
                )
            }
            .padding()
            
            Divider()
            
            VStack {
                HStack {
                    Text("Wait")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(wait, format: .number.rounded(increment: 0.1))
                        .monospacedDigit()
                }
                
                Slider(value: $wait, in: 0...10)
            }
            .padding()
            
            Divider()
          
            Toggle(isOn: $feather){
                Text("Feather Edges")
                    .font(.exampleParameterTitle)
            }
            .padding()
        }
    }
}


#Preview("View Looper") {
    ViewLooperExample()
}
