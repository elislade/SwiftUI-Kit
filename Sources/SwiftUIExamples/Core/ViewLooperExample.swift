import SwiftUIKit


public struct ViewLooperExample: View {
    
    @State private var axis: Axis = .horizontal
    @State private var edgeFadeAmount: Double = 12
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
            HStack(spacing: max(12, edgeFadeAmount)) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.tint)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 60)
                
                VStack(alignment: .leading) {
                    Text("Not Looping")
                    ViewLooper(
                        axis,
                        duration: durationEnum,
                        wait: wait,
                        edgeFadeAmount: edgeFadeAmount
                    ) {
                        Text("Supercalifragilisticexpialidocious")
                            .font(.system(size: 18, design: .serif).bold().italic())
                            .lineLimit(1)
                    }
                }
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
                    
        
                    Text(wait, format: .increment(0.1))
                        .font(.exampleParameterValue)
                    +
                    
                    Text(" Seconds")
                        .font(.caption2)
                        .foregroundColor(.primary.opacity(0.5))
                }
                
                Slider(value: $wait, in: 0...10)
            }
            .exampleParameterCell()
          
            VStack {
                HStack {
                    Text("Edge Fade Amount")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(edgeFadeAmount, format: .increment(0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $edgeFadeAmount, in: 0...24)
            }
            .exampleParameterCell()
        }
    }
}


#Preview("View Looper") {
    ViewLooperExample()
        .previewSize()
}
