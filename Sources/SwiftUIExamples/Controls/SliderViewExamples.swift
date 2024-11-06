import SwiftUIKit


struct SliderViewExamples : View {
    
    @State private var direction = LayoutDirection.leftToRight
    @State private var useStepping = false
    @State private var hitTestHandle = false
    
    @SliderState(in: -4...(-1)) private var x = -2
    @SliderState(in: 1...8) private var y = 2
    
    private var size: Double = 40
    private var radius: Double { size / 2 }
    private var spacing: Double { radius }
    
    private var handle: some View {
        RaisedControlMaterial(RoundedRectangle(cornerRadius: radius).inset(by: 3))
    }
    
    private var bg: some View {
        SunkenControlMaterial(RoundedRectangle(cornerRadius: radius))
    }
    
    var body: some View {
        ExampleView(title: "Slider View"){
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        SliderView(x: _x, y: _y, hitTestHandle: hitTestHandle){ handle.frame(width: size * 3, height: size * 2)
                        }
                        .background{ bg }
                        
                        SliderView(_x, hitTestHandle: hitTestHandle){
                            handle.frame(width: size, height: size)
                        }
                        .background{ bg }
                        .frame(height: size)
                    }
                    
                    SliderView(vertical: _y, hitTestHandle: hitTestHandle){
                        handle.frame(width: size, height: size)
                    }
                    .background{ bg }
                    .frame(width: size)
                }
                
                SliderView(_x)
                    .background{
                        bg
                        
                        SunkenControlMaterial(isTinted: true)
                            .scaleEffect(x: _x.percentComplete, anchor: .leading)
                            .clipShape(Capsule())
                    }
                    .frame(height: size)
            }
            .animation(useStepping ? .bouncy : .fastSpringInteractive, value: x)
            .animation(useStepping ? .bouncy : .fastSpringInteractive, value: y)
            .padding()
            .environment(\.layoutDirection, direction)
        } parameters: {
            HStack {
                Text("X ").font(.exampleParameterTitle) + Text(x, format: .number.rounded(increment: 0.01))
                    .font(.exampleParameterValue)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Y ").font(.exampleParameterTitle) + Text(y, format: .number.rounded(increment: 0.01))
                    .font(.exampleParameterValue)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            ExampleCell.LayoutDirection(value: $direction)
           
            Divider()
            
            Toggle(isOn: $hitTestHandle){
                Text("Hit Test Handle")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            Toggle(isOn: $useStepping){
                Text("Use Stepping")
                    .font(.exampleParameterTitle)
            }
            .padding()
            .syncValue(_useStepping.map{ $0 ? 1 : nil }, $x.step)
            .syncValue(_useStepping.map{ $0 ? 3 : nil }, $y.step)
        }
    }
    
}


#Preview("Slider View") {
    SliderViewExamples()
}
