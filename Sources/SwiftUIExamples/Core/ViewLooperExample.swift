import SwiftUIKit


public struct ViewLooperExample: View {
    
    @State private var axis: Axis = .horizontal
    @State private var feather = true
    @State private var durationSpan: TimeSpanMode = .relative
    @State private var duration: Double = 5
    @State private var wait: Double = 3
    
    enum TimeSpanMode: Sendable {
        case relative
        case absolute
        
        nonisolated var isRelative: Bool {
            self == .relative
        }
    }
    
    private var durationEnum: TimeSpan {
        switch durationSpan {
        case .relative: .millisecondsPerPoint(duration)
        case .absolute: .seconds(duration)
        }
    }
    
    public nonisolated init() {}
    
    public var body: some View {
        ExampleView(title: "View Looper"){
            ViewLooper(
                axis,
                duration: durationEnum,
                wait: wait,
                featherMask: feather
            ) {
                Text("Supercalifragilisticexpialidocious")
                    .font(.system(size: 18, design: .serif).bold().italic())
                    .lineLimit(1)
                    .padding(.horizontal)
            }
        } parameters: {
            HStack {
                Text("Axis")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                SegmentedPicker(selection: $axis.animation(.smooth), items: Axis.allCases){
                    Text("\($0)".capitalized)
                }
                .frame(maxWidth: 200)
            }
            .exampleParameterCell()
            
            VStack {
                HStack(spacing: 0) {
                    Text("Duration")
                        .font(.exampleParameterTitle)

                    Spacer(minLength: 10)
                    
                    Text(duration, format: .increment(0.01))
                        .font(.exampleParameterValue)
                    
                    Picker("", selection: $durationSpan){
                        Text("Milliseconds/Point").tag(TimeSpanMode.relative)
                        Text("Seconds").tag(TimeSpanMode.absolute)
                    }
                }
                
                Slider(value: $duration, in: 0.1...20)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Wait")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Group {
                        Text(wait, format: .increment(0.1)) + Text(" Seconds")
                    }
                    .font(.exampleParameterValue)
                }
                
                Slider(value: $wait, in: 0...10)
            }
            .exampleParameterCell()
          
            Toggle(isOn: $feather){
                Text("Feather Edges")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
        }
    }
}


#Preview("View Looper") {
    ViewLooperExample()
        .previewSize()
}
